# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem "faraday", ">= 1.0", "< 3.0"
gem "rails", ">= 6", "< 8"
gem "rake", "~> 13.1"

group :development, :test do
  gem "sqlite3"
  gem "rspec-rails", "~> 6"
  gem "rspec", "~> 3.13"
  gem "rspec-its", "~> 1.3"
  gem "standard", "~> 1"
  gem "pry", "~> 0.14.1"
  gem "webmock", "~> 3.23"
  gem "bundle-audit", "~> 0.1.0"
end
