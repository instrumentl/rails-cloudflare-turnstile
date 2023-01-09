# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

gem "faraday", "~> 1.0"
gem "rails", "~> 6.1"
gem "rake", "~> 13.0"

group :development, :test do
  gem "sqlite3"
  gem "rspec-rails", "~> 5"
  gem "rspec", "~> 3.0"
  gem "rspec-its", "~> 1.3"
  gem "standard", "~> 1.21.1"
  gem "pry", "~> 0.14.1"
  gem "webmock", "~> 3.18"
  gem "bundle-audit", "~> 0.1.0"
end
