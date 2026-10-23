# Referalli Ruby SDK

The official Ruby client for the [Referalli](https://referalli.com) API: attribution-first affiliate and referral programs.

- One method per API operation, with RBS signatures for every model and method (`sig/`).
- Retries with backoff, idempotency keys, timeouts, auto-paging enumerators and one exception class per error code.
- Webhook signature verification and typed webhook events.
- Standard library only. Ruby 3.1+.

Docs: <https://referalli.com/docs>.

## Install

```bash
gem install referalli
```

or in your Gemfile: `gem "referalli"`.

## Quickstart

Keep the `rk_` API key on your server.

```ruby
require "referalli"

client = Referalli::Client.new(api_key: ENV.fetch("REFERALLI_API_KEY"))

# 1. Create a referral link for a partner
link = client.post_links({
  "programId" => "prg_123",
  "partnerId" => "ptr_123",
  "destinationUrl" => "https://example.com/pricing",
})
puts link["shortUrl"]

# 2. Attribute a signup to the partner who referred it
client.post_referrals_associate({ "programId" => "prg_123", "customerRef" => "user_42", "anonId" => "anon_from_cookie" })

# 3. Track a conversion: a purchase your server has validated
client.post_mobile_purchases({ "eventId" => "order_1001", "customerRef" => "user_42", "amountMinor" => 4900, "currency" => "usd" })
```

Verify a webhook delivery (Rails shown; pass the raw body exactly as received):

```ruby
class ReferalliWebhooksController < ActionController::API
  def create
    event = Referalli::Webhook.construct_event(request.raw_post, request.headers.to_h, ENV.fetch("REFERALLI_WEBHOOK_SECRET"))
    case event
    when Referalli::CommissionEarnedEvent
      Rails.logger.info("commission #{event.data['commissionId']}")
    end
    head :no_content
  rescue Referalli::WebhookVerificationError
    head :bad_request
  end
end
```

## Configuration

```ruby
client = Referalli::Client.new(
  api_key: "rk_live_...",
  base_url: "https://referalli.com", # the default
  timeout: 30,                       # seconds (open, read and write)
  max_retries: 3,                    # retries for idempotent requests
  mode: "live",                      # optional: assert the key's mode ("test" or "live")
)

fast = client.with_options(timeout: 5, max_retries: 0) # a copy with some settings changed
```

Requests are pinned to the API version this SDK was generated against (`Referalli::API_VERSION`); pass `api_version:` to pin another.

### Test mode

Use a test-mode key (`rk_test_...`) to work against your organization's test data. Pass `mode: "test"` to make every request assert it: the API rejects a request whose key is in the other mode with `Referalli::ModeMismatchError`. Webhook events carry `livemode`.

## Errors

Every API error raises a subclass of `Referalli::ApiError` named after its code (`ValidationError`, `NotFoundError`, `RateLimitedError`, ...), with `status`, `code`, `api_message`, `request_id`, `docs_url`, `details` and `retry_after`. Network failures and timeouts raise `Referalli::ConnectionError` after the retries run out. All of them derive from `Referalli::Error`.

```ruby
client = Referalli::Client.new(api_key: "rk_live_...")
begin
  client.get_partners_id("ptr_missing")
rescue Referalli::NotFoundError => e
  puts e.code, e.status, e.request_id, e.docs_url
rescue Referalli::RateLimitedError => e
  puts "retry after #{e.retry_after}"
rescue Referalli::ApiError => e
  puts e.code, e.api_message
end
```

Retries: GET, PUT and DELETE requests, and writes carrying an `Idempotency-Key`, are retried on 429, 5xx and network errors with exponential backoff and jitter, honoring `Retry-After`. POST and PATCH requests always carry a key (generated unless you pass `idempotency_key:`), reused across retries, so a retried write is applied once.

## Pagination

List methods return one page (`{ "data" => [...], "has_more" => ..., "next_cursor" => ... }`); their `_each` twin follows the cursor.

```ruby
client = Referalli::Client.new(api_key: "rk_live_...")
page = client.get_partners(status: "active", limit: 50)
next_page = client.get_partners(status: "active", limit: 50, starting_after: page["next_cursor"])

client.get_referrals_each { |referral| puts referral["id"] }
emails = client.get_partners_each(status: "active").map { |partner| partner["email"] }
```

## Webhooks

`Referalli::Webhook.construct_event(raw_body, headers, secrets)` checks the Standard Webhooks signature (`webhook-id`, `webhook-timestamp`, `webhook-signature`) in constant time, rejects deliveries more than 5 minutes old or ahead (`tolerance_sec:`), and returns the topic's event class (`Referalli::ReferralCreatedEvent`, ...; every topic is in `Referalli::TOPICS`). Pass an array of secrets while you rotate one. `Referalli::Webhook.verify(...)` returns a boolean instead of raising.

```ruby
secrets = ["whsec_current", "whsec_previous"]
ok = Referalli::Webhook.verify(raw_body, headers, secrets)
```

## Any operation by id

```ruby
client = Referalli::Client.new(api_key: "rk_live_...")
partner = client.call("getPartnersId", path: { "id" => "ptr_123" })
client.list_all("getPartners", query: { "status" => "active" }) { |item| puts item["id"] }
```

## Versioning

This SDK follows semantic versioning; see [CHANGELOG.md](./CHANGELOG.md).

## License

MIT. See [LICENSE](./LICENSE).
