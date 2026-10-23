require_relative "lib/referalli/version"

Gem::Specification.new do |spec|
  spec.name = "referalli"
  spec.version = Referalli::VERSION
  spec.authors = ["Referalli"]
  spec.summary = "Official Referalli SDK: attribution-first affiliate and referral programs."
  spec.description = "Typed client for the Referalli API (one method per operation, typed errors, retries, " \
                     "idempotency keys, pagination) plus webhook verification and typed webhook events."
  spec.homepage = "https://github.com/Referalli/referalli-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"
  spec.metadata = {
    "homepage_uri" => "https://github.com/Referalli/referalli-ruby",
    "source_code_uri" => "https://github.com/Referalli/referalli-ruby",
    "changelog_uri" => "https://github.com/Referalli/referalli-ruby/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://referalli.com/docs",
    "rubygems_mfa_required" => "true",
  }
  spec.files = Dir["lib/**/*.rb", "sig/**/*.rbs", "README.md", "LICENSE", "CHANGELOG.md"]
  spec.require_paths = ["lib"]
end
