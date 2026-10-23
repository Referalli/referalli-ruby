# Checks Referalli::Webhook against the shared vectors: ruby test/test_webhooks.rb [vectors.json]
require "json"
require_relative "../lib/referalli"

path = ARGV[0] || File.join(__dir__, "vectors.json")
cases = JSON.parse(File.read(path))["cases"]
failed = cases.reject do |c|
  Referalli::Webhook.verify(c["body"], c["headers"], c["secrets"], now: c["now"]) == c["valid"]
end
failed.each { |c| puts "FAIL #{c['name']}" }
puts "#{cases.size - failed.size}/#{cases.size} passed"
exit(failed.empty? ? 0 : 1)
