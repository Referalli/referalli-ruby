require "json"
require "openssl"

module Referalli
  # A webhook delivery: the envelope every topic shares. Webhook.construct_event
  # returns the topic's subclass (ReferralCreatedEvent, ...; see TOPICS), or
  # this class for a topic this SDK predates.
  class WebhookEvent
    attr_reader :id, :topic, :org_id, :livemode, :created_at, :data, :raw

    def initialize(raw)
      @raw = raw
      @id = raw["id"]
      @topic = raw["topic"]
      @org_id = raw["orgId"]
      @livemode = raw["livemode"]
      @created_at = raw["createdAt"]
      @data = raw["data"]
    end

    def [](key) = @raw[key.to_s]
    def to_h = @raw
  end

  # Verify and parse webhook deliveries (Standard Webhooks signatures).
  #
  # The signature is "v1," + base64 HMAC-SHA256 of "{webhook-id}.{webhook-timestamp}.{raw body}",
  # keyed with the base64 after "whsec_". It is compared in constant time, and deliveries more
  # than tolerance_sec (default 300) from now, in either direction, are rejected.
  module Webhook
    TOLERANCE_SEC = 300

    module_function

    # True when raw_body (exactly as received) was signed with one of secrets within the tolerance.
    # headers maps header names (any case) to values. Pass two secrets while you rotate one.
    def verify(raw_body, headers, secrets, now: nil, tolerance_sec: TOLERANCE_SEC)
      problem(raw_body, headers, secrets, now, tolerance_sec).nil?
    end

    # Verify a delivery and return its typed event. Raises WebhookVerificationError.
    def construct_event(raw_body, headers, secrets, now: nil, tolerance_sec: TOLERANCE_SEC)
      why = problem(raw_body, headers, secrets, now, tolerance_sec)
      raise WebhookVerificationError, why if why

      raw = begin
        JSON.parse(raw_body)
      rescue JSON::ParserError => e
        raise WebhookVerificationError, "the body is not JSON: #{e.message}"
      end
      raise WebhookVerificationError, "the body is not a webhook event" unless raw.is_a?(Hash) && raw["topic"].is_a?(String)

      WEBHOOK_EVENT_CLASSES.fetch(raw["topic"], WebhookEvent).new(raw)
    end

    def problem(raw_body, headers, secrets, now, tolerance_sec)
      lower = headers.to_h.to_h { |k, v| [k.to_s.downcase.tr("_", "-").delete_prefix("http-"), v.is_a?(Array) ? v.first : v] }
      id = lower["webhook-id"]
      ts = lower["webhook-timestamp"].to_s
      sig = lower["webhook-signature"]
      return "missing webhook-id, webhook-timestamp or webhook-signature header" if id.nil? || ts.empty? || sig.nil?
      return "webhook-timestamp is not a unix timestamp" unless ts.match?(/\A\d+\z/)

      current = now.nil? ? Time.now.to_f : now.to_f
      return "webhook-timestamp is outside the tolerance (replayed or clock skew)" if (current - ts.to_i).abs > tolerance_sec

      provided = sig.to_s.split(" ").select { |p| p.start_with?("v1,") }
      message = "#{id}.#{ts}.#{raw_body}"
      matched = Array(secrets).any? do |secret|
        key = secret.start_with?("whsec_") ? secret.delete_prefix("whsec_").unpack1("m") : secret
        expected = "v1," + [OpenSSL::HMAC.digest("SHA256", key, message)].pack("m0")
        provided.any? { |p| p.bytesize == expected.bytesize && OpenSSL.fixed_length_secure_compare(p, expected) }
      end
      matched ? nil : "no signature matches the secret"
    end
  end

  # The verifier under its earlier name.
  def self.verify_webhook(raw_body, headers, secrets, now: nil, tolerance_sec: Webhook::TOLERANCE_SEC)
    Webhook.verify(raw_body, headers, secrets, now: now, tolerance_sec: tolerance_sec)
  end
end

require_relative "webhook_events"
