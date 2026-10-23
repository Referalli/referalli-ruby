# Unit tests: retry policy, options, webhooks and the README samples. ruby -Ilib test/test_client.rb
require "minitest/autorun"
require "base64"
require "json"
require "openssl"
require "ripper"
require_relative "../lib/referalli"

class ReferalliClientTest < Minitest::Test
  SECRET = "whsec_#{Base64.strict_encode64('0123456789abcdef0123456789abcdef')}".freeze

  def sign(body, secret, ts: Time.now.to_i, id: "msg_1")
    key = Base64.decode64(secret.delete_prefix("whsec_"))
    sig = Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", key, "#{id}.#{ts}.#{body}"))
    { "webhook-id" => id, "webhook-timestamp" => ts.to_s, "webhook-signature" => "v1,#{sig}" }
  end

  def test_construct_event_returns_the_topic_class
    body = JSON.generate({ id: "evt_1", topic: "referral.created", orgId: "org_1", livemode: false, createdAt: "2026-10-21T12:00:00Z", data: { partnerId: "ptr_1" } })
    event = Referalli::Webhook.construct_event(body, sign(body, SECRET), [SECRET])
    assert_instance_of Referalli::ReferralCreatedEvent, event
    assert_equal "ptr_1", event.data["partnerId"]
    assert_equal "org_1", event.org_id
    assert_includes Referalli::TOPICS, "referral.created"
  end

  def test_construct_event_rejects_bad_signatures_and_stale_timestamps
    body = '{"id":"evt_1","topic":"referral.created","data":{}}'
    assert_raises(Referalli::WebhookVerificationError) { Referalli::Webhook.construct_event(body, sign(body, SECRET), "whsec_b3RoZXI=") }
    assert_raises(Referalli::WebhookVerificationError) { Referalli::Webhook.construct_event(body, sign(body, SECRET, ts: Time.now.to_i - 301), SECRET) }
    assert Referalli::Webhook.verify(body, sign(body, SECRET, ts: 1000), SECRET, now: 1200)
    refute Referalli::Webhook.verify("#{body} ", sign(body, SECRET), SECRET)
    # Rack-style env keys work too.
    rack = sign(body, SECRET).to_h { |k, v| ["HTTP_#{k.upcase.tr('-', '_')}", v] }
    assert Referalli::Webhook.verify(body, rack, SECRET)
  end

  def test_unknown_topic_falls_back_to_the_base_event
    body = '{"id":"evt_1","topic":"brand.new","data":{"x":1}}'
    event = Referalli::Webhook.construct_event(body, sign(body, SECRET), SECRET)
    assert_equal Referalli::WebhookEvent, event.class
  end

  def test_retry_policy_and_idempotency_keys
    client = Referalli::Client.new(api_key: "k")
    assert client.send(:retryable?, "GET", {}, 0)
    assert client.send(:retryable?, "POST", { "idempotency-key" => "k" }, 0)
    refute client.send(:retryable?, "POST", {}, 0)
    refute client.send(:retryable?, "GET", {}, 3)
    assert client.send(:headers_for, "PATCH", "{}", nil).key?("idempotency-key")
    refute client.send(:headers_for, "GET", nil, nil).key?("idempotency-key")
    headers = Referalli::Client.new(api_key: "k", mode: "test").send(:headers_for, "GET", nil, nil)
    assert_equal "test", headers["referalli-mode"]
    assert_equal "referalli-ruby/#{Referalli::VERSION}", headers["user-agent"]
  end

  def test_with_options_copies
    client = Referalli::Client.new(api_key: "k")
    fast = client.with_options(timeout: 1, mode: "test")
    assert_equal 1, fast.timeout
    assert_equal "test", fast.mode
    assert_equal 30, client.timeout
    assert_nil client.mode
  end

  def test_readme_samples_parse_and_use_real_methods
    readme = File.read(File.join(__dir__, "..", "README.md"))
    blocks = readme.scan(/```ruby\n(.*?)```/m).flatten
    assert_operator blocks.size, :>=, 5
    methods = Referalli::Client.instance_methods
    blocks.each do |block|
      refute_nil Ripper.sexp(block), "README block does not parse:\n#{block}"
      block.scan(/\b(?:client|fast)\.([a-z_]+)/).flatten.each { |m| assert_includes methods, m.to_sym }
      block.scan(/Referalli::([A-Z][A-Za-z]+)/).flatten.each { |c| assert Referalli.const_defined?(c), c }
      block.scan(/\.call\("(\w+)"/).flatten.each { |op| assert Referalli::Operations::OPERATIONS.key?(op), op }
    end
  end
end
