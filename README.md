# RailsCloudflareTurnstile

This is a Rails plugin adding support for [Cloudflare Turnstile](https://www.cloudflare.com/products/turnstile/). It works with Rails 6+, and Ruby 3.x.

[![CI](https://github.com/instrumentl/rails-cloudflare-turnstile/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/instrumentl/rails-cloudflare-turnstile/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/rails_cloudflare_turnstile.svg)](https://badge.fury.io/rb/rails_cloudflare_turnstile)

## Usage

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails_cloudflare_turnstile'
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
To totally disable Turnstile, you can set `c.enabled = false` and all other config values are ignored.

To use Turnstile for a view:

   1. Call `cloudflare_turnstile_script_tag` in your layout
   2. Call `cloudflare_turnstile` in your form View. Keyword arguments are passed to the tag helper (for example, to set the `tabindex` option, you could use `cloudflare_turnstile(data: {tabindex: 0})`)
   3. Call `validate_cloudflare_turnstile` as a `before_action` in your controller.

If the challenge fails, the exception `RailsCloudflareTurnstile::Forbidden` will be raised; you should handle this with
a `rescue_from` block.

By default, in development and test mode, a special mock view will be inserted if real credentials are not present. To
disable this, set the `mock_enabled` property of the configuration to false.

## Customizing theme and size

The widget theme and size can be configured globally and overridden per instance:

**Global configuration** (set in initializer):
```ruby
RailsCloudflareTurnstile.configure do |c|
  c.size = :normal   # :normal (default), :compact, or :flexible
  c.theme = :dark    # :auto (default), :light, or :dark
end
```

**Per-instance override** (in your view):
```erb
<%= cloudflare_turnstile(data: {theme: "dark"}) %>
<%= cloudflare_turnstile(data: {size: "compact"}) %>
<%= cloudflare_turnstile(data: {size: "compact", theme: "dark"}) %>
```

Per-instance values will override the global configuration. Both strings and symbols are accepted.

## License
The gem is available as open source under the terms of the [ISC License](LICENSE.txt).
