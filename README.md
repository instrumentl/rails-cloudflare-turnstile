# RailsCloudflareTurnstile

This is a Rails plugin adding support for [Cloudflare Turnstile](https://www.cloudflare.com/products/turnstile/)

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails-cloudflare-turnstile'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install rails_cloudflare_turnstile
```

Next, configure it by creating a `config/initializers/cloudflare_turnstile.rb` with contents like the following:

```ruby
RailsCloudflareTurnstile.configure do |c|
  c.site_key = "XXXXXX"
  c.secret_key = "XXXXXXXX"
  c.fail_open = true
end
```

To use Turnstile for a view:

   1. Call `cloudflare_turnstile_script_tag` in your layout
   2. Call `cloudflare_turnstile` in your form View
   3. Call `enable_cloudflare_turnstile` in your controller

## License
The gem is available as open source under the terms of the [ISC License](LICENSE.txt).
