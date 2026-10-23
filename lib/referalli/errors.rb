# Code generated from the Referalli OpenAPI document. DO NOT EDIT.
# Changes belong in the generator, which overwrites this file.

module Referalli
  # Base class for every error this SDK raises.
  class Error < StandardError; end

  # The API could not be reached (network error or timeout), after retries.
  class ConnectionError < Error; end

  # A webhook delivery failed signature or timestamp verification, or isn't a JSON event.
  class WebhookVerificationError < Error; end

  # The API answered with an error. `code` is stable; `docs_url` explains it.
  class ApiError < Error
    attr_reader :status, :code, :api_message, :request_id, :docs_url, :details, :retry_after, :headers

    def initialize(status:, code:, message:, request_id: nil, docs_url: nil, details: nil, retry_after: nil, headers: {})
      @status = status
      @code = code
      @api_message = message
      @request_id = request_id
      @docs_url = docs_url
      @details = details
      @retry_after = retry_after
      @headers = headers
      super("#{code} (#{status}): #{message}")
    end
  end

  # `validation_error` (HTTP 400).
  class ValidationError < ApiError; end

  # `mode_mismatch` (HTTP 400).
  class ModeMismatchError < ApiError; end

  # `bad_request` (HTTP 400).
  class BadRequestError < ApiError; end

  # `unauthorized` (HTTP 401).
  class AuthenticationError < ApiError; end

  # `step_up_required` (HTTP 401).
  class StepUpRequiredError < ApiError; end

  # `payment_required` (HTTP 402).
  class PaymentRequiredError < ApiError; end

  # `forbidden` (HTTP 403).
  class PermissionDeniedError < ApiError; end

  # `webhooks_disabled` (HTTP 403).
  class WebhooksDisabledError < ApiError; end

  # `sso_required` (HTTP 403).
  class SsoRequiredError < ApiError; end

  # `access_suspended` (HTTP 403).
  class AccessSuspendedError < ApiError; end

  # `not_found` (HTTP 404).
  class NotFoundError < ApiError; end

  # `conflict` (HTTP 409).
  class ConflictError < ApiError; end

  # `idempotency_in_progress` (HTTP 409).
  class IdempotencyInProgressError < ApiError; end

  # `replay` (HTTP 409).
  class ReplayError < ApiError; end

  # `live_mode_only` (HTTP 409).
  class LiveModeOnlyError < ApiError; end

  # `test_mode_only` (HTTP 409).
  class TestModeOnlyError < ApiError; end

  # `test_mode_unsupported` (HTTP 409).
  class TestModeUnsupportedError < ApiError; end

  # `gone` (HTTP 410).
  class GoneError < ApiError; end

  # `idempotency_key_reused` (HTTP 422).
  class IdempotencyKeyReusedError < ApiError; end

  # `payload_too_large` (HTTP 413).
  class PayloadTooLargeError < ApiError; end

  # `connection_paused` (HTTP 423).
  class ConnectionPausedError < ApiError; end

  # `rate_limited` (HTTP 429).
  class RateLimitedError < ApiError; end

  # `internal_error` (HTTP 500).
  class InternalServerError < ApiError; end

  # `atlas_error` (HTTP 502).
  class AtlasError < ApiError; end

  # `sso_provider_error` (HTTP 502).
  class SsoProviderError < ApiError; end

  # `sso_not_configured` (HTTP 503).
  class SsoNotConfiguredError < ApiError; end

  ERROR_CLASSES = {
    "validation_error" => ValidationError,
    "mode_mismatch" => ModeMismatchError,
    "bad_request" => BadRequestError,
    "unauthorized" => AuthenticationError,
    "step_up_required" => StepUpRequiredError,
    "payment_required" => PaymentRequiredError,
    "forbidden" => PermissionDeniedError,
    "webhooks_disabled" => WebhooksDisabledError,
    "sso_required" => SsoRequiredError,
    "access_suspended" => AccessSuspendedError,
    "not_found" => NotFoundError,
    "conflict" => ConflictError,
    "idempotency_in_progress" => IdempotencyInProgressError,
    "replay" => ReplayError,
    "live_mode_only" => LiveModeOnlyError,
    "test_mode_only" => TestModeOnlyError,
    "test_mode_unsupported" => TestModeUnsupportedError,
    "gone" => GoneError,
    "idempotency_key_reused" => IdempotencyKeyReusedError,
    "payload_too_large" => PayloadTooLargeError,
    "connection_paused" => ConnectionPausedError,
    "rate_limited" => RateLimitedError,
    "internal_error" => InternalServerError,
    "atlas_error" => AtlasError,
    "sso_provider_error" => SsoProviderError,
    "sso_not_configured" => SsoNotConfiguredError,
  }.freeze
end
