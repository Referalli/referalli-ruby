# Code generated from the Referalli OpenAPI document. DO NOT EDIT.
# Changes belong in the generator, which overwrites this file.

module Referalli
  # One class per webhook topic (see WebhookEvent); Webhook.construct_event picks it by topic.
  # `billing_event.recorded`: A billing event was recorded
  class BillingEventRecordedEvent < WebhookEvent
    TOPIC = "billing_event.recorded"
  end

  # `click.recorded`: A tracked click was recorded
  class ClickRecordedEvent < WebhookEvent
    TOPIC = "click.recorded"
  end

  # `commission.earned`: A commission line was earned
  class CommissionEarnedEvent < WebhookEvent
    TOPIC = "commission.earned"
  end

  # `commission.reversed`: A commission line was reversed
  class CommissionReversedEvent < WebhookEvent
    TOPIC = "commission.reversed"
  end

  # `commission.settled`: A commission line was settled by the merchant
  class CommissionSettledEvent < WebhookEvent
    TOPIC = "commission.settled"
  end

  # `credit.redeemed`: A referee reward was redeemed
  class CreditRedeemedEvent < WebhookEvent
    TOPIC = "credit.redeemed"
  end

  # `customer.aliased`: A customer's id changed
  class CustomerAliasedEvent < WebhookEvent
    TOPIC = "customer.aliased"
  end

  # `deal.submitted`: A partner registered a deal
  class DealSubmittedEvent < WebhookEvent
    TOPIC = "deal.submitted"
  end

  # `dispute.resolved`: A partner dispute was resolved
  class DisputeResolvedEvent < WebhookEvent
    TOPIC = "dispute.resolved"
  end

  # `fraud.case_opened`: A fraud case was opened
  class FraudCaseOpenedEvent < WebhookEvent
    TOPIC = "fraud.case_opened"
  end

  # `partner.applied`: A partner applied to a program
  class PartnerAppliedEvent < WebhookEvent
    TOPIC = "partner.applied"
  end

  # `partner.approved`: A partner was approved
  class PartnerApprovedEvent < WebhookEvent
    TOPIC = "partner.approved"
  end

  # `partner.enrolled`: A partner was enrolled
  class PartnerEnrolledEvent < WebhookEvent
    TOPIC = "partner.enrolled"
  end

  # `partner.level_up`: A partner reached a new level
  class PartnerLevelUpEvent < WebhookEvent
    TOPIC = "partner.level_up"
  end

  # `payout.cancelled`: A payout was cancelled
  class PayoutCancelledEvent < WebhookEvent
    TOPIC = "payout.cancelled"
  end

  # `payout.failed`: A payout failed
  class PayoutFailedEvent < WebhookEvent
    TOPIC = "payout.failed"
  end

  # `payout.scheduled`: A payout was created in a run
  class PayoutScheduledEvent < WebhookEvent
    TOPIC = "payout.scheduled"
  end

  # `payout.sent`: A payout was paid
  class PayoutSentEvent < WebhookEvent
    TOPIC = "payout.sent"
  end

  # `payout.submitted`: A payout was submitted to the provider
  class PayoutSubmittedEvent < WebhookEvent
    TOPIC = "payout.submitted"
  end

  # `privacy.request_completed`: A data-subject request finished
  class PrivacyRequestCompletedEvent < WebhookEvent
    TOPIC = "privacy.request_completed"
  end

  # `referee_reward.earned`: A referred customer earned their reward
  class RefereeRewardEarnedEvent < WebhookEvent
    TOPIC = "referee_reward.earned"
  end

  # `referral.approved`: A held referral was approved
  class ReferralApprovedEvent < WebhookEvent
    TOPIC = "referral.approved"
  end

  # `referral.created`: A customer was attributed to a partner
  class ReferralCreatedEvent < WebhookEvent
    TOPIC = "referral.created"
  end

  # `referral.held`: A referral was held for review
  class ReferralHeldEvent < WebhookEvent
    TOPIC = "referral.held"
  end

  # `referral.paused`: A referral was paused
  class ReferralPausedEvent < WebhookEvent
    TOPIC = "referral.paused"
  end

  # `referral.reassigned`: A referral moved to another partner
  class ReferralReassignedEvent < WebhookEvent
    TOPIC = "referral.reassigned"
  end

  # `referral.rejected`: A self-referral was refused
  class ReferralRejectedEvent < WebhookEvent
    TOPIC = "referral.rejected"
  end

  # `referral.resumed`: A paused referral was resumed
  class ReferralResumedEvent < WebhookEvent
    TOPIC = "referral.resumed"
  end

  # `referral.voided`: A referral was voided
  class ReferralVoidedEvent < WebhookEvent
    TOPIC = "referral.voided"
  end

  # `roi.pattern_detected`: A value pattern changed
  class RoiPatternDetectedEvent < WebhookEvent
    TOPIC = "roi.pattern_detected"
  end

  # `roi.payback_reached`: A credit grant paid back
  class RoiPaybackReachedEvent < WebhookEvent
    TOPIC = "roi.payback_reached"
  end

  # `tax.form_delivered`: A tax form was delivered to a partner
  class TaxFormDeliveredEvent < WebhookEvent
    TOPIC = "tax.form_delivered"
  end

  # `webhook_endpoint.disabled`: A failing webhook endpoint was disabled
  class WebhookEndpointDisabledEvent < WebhookEvent
    TOPIC = "webhook_endpoint.disabled"
  end

  # Topic => event class.
  WEBHOOK_EVENT_CLASSES = {
    "billing_event.recorded" => BillingEventRecordedEvent,
    "click.recorded" => ClickRecordedEvent,
    "commission.earned" => CommissionEarnedEvent,
    "commission.reversed" => CommissionReversedEvent,
    "commission.settled" => CommissionSettledEvent,
    "credit.redeemed" => CreditRedeemedEvent,
    "customer.aliased" => CustomerAliasedEvent,
    "deal.submitted" => DealSubmittedEvent,
    "dispute.resolved" => DisputeResolvedEvent,
    "fraud.case_opened" => FraudCaseOpenedEvent,
    "partner.applied" => PartnerAppliedEvent,
    "partner.approved" => PartnerApprovedEvent,
    "partner.enrolled" => PartnerEnrolledEvent,
    "partner.level_up" => PartnerLevelUpEvent,
    "payout.cancelled" => PayoutCancelledEvent,
    "payout.failed" => PayoutFailedEvent,
    "payout.scheduled" => PayoutScheduledEvent,
    "payout.sent" => PayoutSentEvent,
    "payout.submitted" => PayoutSubmittedEvent,
    "privacy.request_completed" => PrivacyRequestCompletedEvent,
    "referee_reward.earned" => RefereeRewardEarnedEvent,
    "referral.approved" => ReferralApprovedEvent,
    "referral.created" => ReferralCreatedEvent,
    "referral.held" => ReferralHeldEvent,
    "referral.paused" => ReferralPausedEvent,
    "referral.reassigned" => ReferralReassignedEvent,
    "referral.rejected" => ReferralRejectedEvent,
    "referral.resumed" => ReferralResumedEvent,
    "referral.voided" => ReferralVoidedEvent,
    "roi.pattern_detected" => RoiPatternDetectedEvent,
    "roi.payback_reached" => RoiPaybackReachedEvent,
    "tax.form_delivered" => TaxFormDeliveredEvent,
    "webhook_endpoint.disabled" => WebhookEndpointDisabledEvent,
  }.freeze

  # Every topic the API publishes.
  TOPICS = WEBHOOK_EVENT_CLASSES.keys.freeze
end
