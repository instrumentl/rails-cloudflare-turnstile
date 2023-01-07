# frozen_string_literal: true

require_relative "lib/rails_cloudflare_turnstile/version"

Gem::Specification.new do |spec|
  spec.name = "rails_cloudflare_turnstile"
  spec.version = RailsCloudflareTurnstile::VERSION
  spec.authors = ["James Brown"]
  spec.email = ["james@instrumentl.com"]

  spec.summary = "Rails extension for Cloudflare's Turnstile CAPTCHA alternative"
  spec.description = "Rails extension for Cloudflare's Turnstile CAPTCHA alternative"
  spec.homepage = "https://github.com/instrumentl/rails_cloudflare-turnstile"
  spec.license = "ISC"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/instrumentl/rails_cloudflare-turnstile"
  spec.metadata["source_code_uri"] = "https://github.com/instrumentl/rails_cloudflare-turnstile"
  spec.metadata["changelog_uri"] = "https://github.com/dotenv-org/cloudflare_turnstile"

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 5.0"
  spec.add_dependency "faraday", ">= 1.0"
end
