require "json"
require "net/http"
require "securerandom"
require "time"
require "uri"

module Referalli
  DEFAULT_BASE_URL = "https://referalli.com".freeze
  RETRY_STATUSES = [429, 500, 502, 503, 504].freeze
  # Methods that are safe to retry without an idempotency key.
  IDEMPOTENT_METHODS = %w[GET HEAD PUT DELETE OPTIONS].freeze
  # Writes that get a generated Idempotency-Key when you don't pass one.
  KEYED_METHODS = %w[POST PATCH].freeze
  MAX_RETRY_DELAY = 30.0

  # Server-side client. Keep the rk_ key on your server.
  #
  # Every operation has a method named after its operationId (post_links,
  # get_partners, ...). Writes carry an Idempotency-Key (generated unless you
  # pass idempotency_key:) that is reused across retries. Idempotent requests
  # are retried on 429, 5xx and network errors with exponential backoff and
  # jitter, honoring Retry-After.
  #
  # mode: "test" (or "live") asserts the key's mode on every request: the API
  # refuses a request whose key is in the other mode.
  class Client
    include Operations

    attr_reader :base_url, :api_version, :timeout, :max_retries, :mode

    def initialize(api_key: nil, base_url: DEFAULT_BASE_URL, timeout: 30, max_retries: 3, retry_base_delay: 0.5,
                   api_version: API_VERSION, mode: nil, default_headers: {})
      raise ArgumentError, 'mode must be "test", "live" or nil' unless [nil, "test", "live"].include?(mode)

      @api_key = api_key
      @base_url = (base_url || DEFAULT_BASE_URL).chomp("/")
      @timeout = timeout
      @max_retries = max_retries
      @retry_base_delay = retry_base_delay
      @api_version = api_version
      @mode = mode
      @default_headers = default_headers
    end

    # A copy of this client with some settings changed:
    #   client.with_options(timeout: 5, max_retries: 0).get_partners
    def with_options(**changes)
      Client.new(api_key: @api_key, base_url: changes.fetch(:base_url, @base_url), timeout: changes.fetch(:timeout, @timeout),
                 max_retries: changes.fetch(:max_retries, @max_retries),
                 retry_base_delay: changes.fetch(:retry_base_delay, @retry_base_delay),
                 api_version: changes.fetch(:api_version, @api_version), mode: changes.fetch(:mode, @mode),
                 default_headers: @default_headers)
    end

    # Call any operation by its id (see Operations::OPERATIONS) with wire-named params.
    def call(operation_id, path: {}, query: {}, body: nil, idempotency_key: nil)
      _method, _path, path_params, query_params, has_body, _kind, name = Operations::OPERATIONS.fetch(operation_id)
      args = path_params.map { |p| (path || {}).fetch(p) }
      args << body if has_body
      wire_to_ruby = query_params.to_h
      kwargs = (query || {}).to_h { |k, v| [wire_to_ruby.fetch(k.to_s).to_sym, v] }
      send(name, *args, idempotency_key: idempotency_key, **kwargs)
    end

    # Every item of a list operation, following next_cursor.
    def list_all(operation_id, path: {}, query: {}, &block)
      q = (query || {}).to_h { |k, v| [k.to_s, v] }
      paginate(->(cursor) { call(operation_id, path: path, query: q.merge("starting_after" => cursor)) }, &block)
    end

    private

    def seg(value)
      URI.encode_www_form_component(value.to_s).gsub("+", "%20")
    end

    def paginate(fetch)
      enum = Enumerator.new do |y|
        cursor = nil
        loop do
          page = fetch.call(cursor)
          page["data"].each { |item| y << item }
          break unless page["has_more"] && page["next_cursor"]

          cursor = page["next_cursor"]
        end
      end
      block_given? ? enum.each { |item| yield item } : enum
    end

    def headers_for(method, payload, idempotency_key)
      headers = {
        "accept" => "application/json",
        # Wire protocol: the API reads these header names.
        "referalli-version" => @api_version,
        "user-agent" => "referalli-ruby/#{VERSION}",
      }.merge(@default_headers)
      headers["referalli-mode"] = @mode if @mode
      headers["authorization"] = "Bearer #{@api_key}" if @api_key
      headers["content-type"] = "application/json" if payload
      if idempotency_key
        headers["idempotency-key"] = idempotency_key
      elsif KEYED_METHODS.include?(method)
        headers["idempotency-key"] = SecureRandom.uuid
      end
      headers
    end

    # Only idempotent requests are retried: safe methods, or writes that carry an idempotency key.
    def retryable?(method, headers, attempt)
      attempt < @max_retries && (IDEMPOTENT_METHODS.include?(method) || headers.key?("idempotency-key"))
    end

    def request(method, path, query: {}, body: nil, idempotency_key: nil, kind: :json)
      uri = URI("#{@base_url}#{path}")
      params = query.reject { |_, v| v.nil? }.map { |k, v| [k, v.to_s] }
      uri.query = URI.encode_www_form(params) unless params.empty?
      payload = body.nil? ? nil : JSON.generate(body)
      headers = headers_for(method, payload, idempotency_key)

      attempt = 0
      loop do
        begin
          res = send_request(method, uri, headers, payload)
        rescue SocketError, Timeout::Error, SystemCallError, IOError, OpenSSL::SSL::SSLError => e
          raise ConnectionError, e.message unless retryable?(method, headers, attempt)

          sleep(delay(attempt, nil))
          attempt += 1
          next
        end
        status = res.code.to_i
        if status.between?(200, 299)
          return res.body.to_s if kind == :text
          return nil if kind == :empty || res.body.to_s.empty?

          return JSON.parse(res.body)
        end
        retry_after = parse_retry_after(res["retry-after"])
        if RETRY_STATUSES.include?(status) && retryable?(method, headers, attempt)
          sleep(delay(attempt, retry_after))
          attempt += 1
          next
        end
        raise api_error(status, res, retry_after)
      end
    end

    def send_request(method, uri, headers, payload)
      klass = Net::HTTP.const_get(method.capitalize)
      req = klass.new(uri)
      headers.each { |k, v| req[k] = v }
      req.body = payload if payload
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https", read_timeout: @timeout,
                                              open_timeout: @timeout, write_timeout: @timeout) { |http| http.request(req) }
    end

    # Exponential backoff with jitter; Retry-After wins when the server sends it.
    def delay(attempt, retry_after)
      return retry_after.clamp(0, MAX_RETRY_DELAY) if retry_after

      [@retry_base_delay * (2**attempt), MAX_RETRY_DELAY].min * (0.5 + (rand * 0.5))
    end

    def parse_retry_after(value)
      return nil if value.nil? || value.empty?

      Float(value)
    rescue ArgumentError
      begin
        [Time.httpdate(value) - Time.now, 0].max
      rescue ArgumentError
        nil
      end
    end

    def api_error(status, res, retry_after)
      err = begin
        JSON.parse(res.body.to_s)["error"]
      rescue StandardError
        nil
      end
      err = { "code" => "http_error", "message" => res.body.to_s.empty? ? "HTTP #{status}" : res.body.to_s } unless err.is_a?(Hash)
      code = (err["code"] || "http_error").to_s
      klass = ERROR_CLASSES.fetch(code, ApiError)
      klass.new(status: status, code: code, message: err["message"].to_s, request_id: err["requestId"] || res["x-request-id"],
                docs_url: err["docs_url"], details: err["details"], retry_after: retry_after, headers: res.to_hash)
    end
  end
end
