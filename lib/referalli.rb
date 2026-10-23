# Official Referalli SDK for Ruby (standard library only).
#
#   require "referalli"
#   client = Referalli::Client.new(api_key: ENV.fetch("REFERALLI_API_KEY"))
#   link = client.post_links({ "programId" => "prg_...", "partnerId" => "ptr_...", "destinationUrl" => "https://example.com" })
#   client.get_partners_each(status: "active") { |partner| puts partner["email"] }

require_relative "referalli/version"
require_relative "referalli/errors"
require_relative "referalli/operations"
require_relative "referalli/client"
require_relative "referalli/webhooks"
