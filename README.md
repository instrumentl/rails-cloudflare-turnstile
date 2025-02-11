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
disable this, set the `mock_enable` property of the configuration to false.

## Client Configuration

The `cloudflare_turnstile` view helper simplifies Turnstile implementation by pre-populating the Turnstile tag with `sitekey`, `size`, `action`, and `theme`. However, you can pass your own [data attributes supported by Turnstile](https://developers.cloudflare.com/turnstile/get-started/client-side-rendering/#configurations) to the `cloudflare_turnstile` helper as needed.

Example usage:
```erb
<%= cloudflare_turnstile('data-callback': 'exampleJsCallback', 'data-error-callback': 'exampleErrorJsCallback') %>
```

### Configuration Reference Table

Retrieved February 2025 from [Cloudflare Configuration](https://developers.cloudflare.com/turnstile/get-started/client-side-rendering/#configurations).

This table outlines the available configuration options for Turnstile, their equivalent `data-` attributes, whether they are pre-populated by the helper, and a brief description.

| JavaScript Parameter          | `data-` Attribute Equivalent          | Pre-populated? | Description |
|-------------------------------|---------------------------------------|---------------|-------------|
| `sitekey`                     | `data-sitekey`                        | **Yes**       | The public site key for the Turnstile instance. |
| `action`                      | `data-action`                         | **Yes**       | Custom string categorizing the request, useful for analytics. Max 32 alphanumeric characters. |
| `cData`                       | `data-cdata`                          |               | A payload that attaches customer data to the challenge (max 255 alphanumeric characters). |
| `callback`                    | `data-callback`                       |               | JavaScript function executed on successful validation. |
| `error-callback`              | `data-error-callback`                 |               | JavaScript function executed on error (e.g., network issue, challenge failure). |
| `execution`                   | `data-execution`                      |               | Controls when to obtain a token (`render`, `execute`). Defaults to `render`. |
| `expired-callback`            | `data-expired-callback`               |               | JavaScript function executed when the token expires without resetting the widget. |
| `before-interactive-callback` | `data-before-interactive-callback`    |               | JavaScript function executed before the challenge enters interactive mode. |
| `after-interactive-callback`  | `data-after-interactive-callback`     |               | JavaScript function executed when the challenge exits interactive mode. |
| `unsupported-callback`        | `data-unsupported-callback`           |               | JavaScript function executed if the client/browser is not supported. |
| `theme`                       | `data-theme`                          | **Yes**       | Controls widget theme (`auto`, `light`, `dark`). Defaults to `auto`. |
| `language`                    | `data-language`                       |               | Widget language. `auto` (default) or ISO 639-1 language code (e.g., `en`, `en-US`). |
| `tabindex`                    | `data-tabindex`                       |               | The `tabindex` of Turnstile's iframe for accessibility. Defaults to `0`. |
| `timeout-callback`            | `data-timeout-callback`               |               | JavaScript function executed if the interactive challenge times out. |
| `response-field`              | `data-response-field`                 |               | Boolean to control whether an input element with the response token is created. Defaults to `true`. |
| `response-field-name`         | `data-response-field-name`            |               | Name of the input element. Defaults to `cf-turnstile-response`. |
| `size`                        | `data-size`                           | **Yes**       | Widget size (`normal`, `flexible`, `compact`). |
| `retry`                       | `data-retry`                          |               | Controls automatic retries (`auto`, `never`). Defaults to `auto`. |
| `retry-interval`              | `data-retry-interval`                 |               | Retry interval in milliseconds (`8000` default, max `900000`). |
| `refresh-expired`             | `data-refresh-expired`                |               | Token refresh behavior (`auto`, `manual`, `never`). Defaults to `auto`. |
| `refresh-timeout`             | `data-refresh-timeout`                |               | Controls refresh behavior on interactive challenge timeout (`auto`, `manual`, `never`). Defaults to `auto`. |
| `appearance`                  | `data-appearance`                     |               | Widget visibility (`always`, `execute`, `interaction-only`). Defaults to `always`. |
| `feedback-enabled`            | `data-feedback-enabled`               |               | Allows visitor feedback on widget failure (`true`, `false`). Defaults to `true`. |

For additional details, refer to the [Cloudflare Turnstile documentation](https://developers.cloudflare.com/turnstile/get-started/client-side-rendering/#configurations).

## License
The gem is available as open source under the terms of the [ISC License](LICENSE.txt).
