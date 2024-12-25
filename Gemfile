# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem "base64"
gem "mutex_m"
gem "faraday", ">= 1.0", "< 3.0"
gem "rails", ">= 6", "< 8"
gem "rake", "~> 13.2"

group :development, :test do
  gem "sqlite3"
  gem "rspec-rails", "~> 7"
  gem "rspec", "~> 3.13"
  gem "rspec-its", "~> 2.0"
  gem "standard", "~> 1"
  gem "pry", "~> 0.15.2"
  gem "webmock", "~> 3.24"
  gem "bundle-audit", "~> 0.1.0"
end
