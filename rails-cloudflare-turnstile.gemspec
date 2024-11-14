# frozen_string_literal: true

require_relative "lib/rails_cloudflare_turnstile/version"

Gem::Specification.new do |spec|
  spec.name = "rails_cloudflare_turnstile"
  spec.version = RailsCloudflareTurnstile::VERSION
  spec.authors = ["James Brown"]
  spec.email = ["james@instrumentl.com"]

  spec.summary = "Rails extension for Cloudflare's Turnstile CAPTCHA alternative"
  spec.description = <<-EOF
    Rails extension for Cloudflare's Turnstile CAPTCHA alternative. This gem should work with
    Rails 6.x and 7.x, and with Faraday 1.x and 2.x.
  EOF
  spec.homepage = "https://github.com/instrumentl/rails-cloudflare-turnstile"
  spec.license = "ISC"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/instrumentl/rails-cloudflare-turnstile"
  spec.metadata["changelog_uri"] = "https://github.com/instrumentl/rails-cloudflare-turnstile/blob/main/CHANGELOG.md"

  spec.files = Dir["{app,lib}/**/*", "LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0", "< 9"
  spec.add_dependency "faraday", ">= 1.0", "< 3.0"
end
