# RailsCloudflareTurnstile

This is a Rails plugin adding support for [Cloudflare Turnstile](https://www.cloudflare.com/products/turnstile/). It works with Rails 6+, and Ruby 3.2+.

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

## Using with Turbo

Cloudflare's default (implicit) rendering scans for widgets when its script loads. Turbo can insert new forms without loading that script again, leaving those forms without a widget or response token.

By default, `cloudflare_turnstile_script_tag` adds `data-turbo-track="reload"` and `data-turbo-temporary`. This can force full page loads on Turbo Drive visits. It does not initialize widgets inserted by Turbo Frames, Streams, or form responses rendered without a full reload.

To keep Turbo Drive, use explicit rendering and a Stimulus controller:

```erb
<%# layout <head>: the controller handles mock widgets without the mock script %>
<% if RailsCloudflareTurnstile.enabled? %>
  <%= cloudflare_turnstile_script_tag(explicit: true, turbo_reload: false) %>
<% end %>

<%# form %>
<%= cloudflare_turnstile(data: {controller: "turnstile"}) %>
```

```js
// app/javascript/controllers/turnstile_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Cloudflare uses data-action itself, so bind Turbo events in JavaScript.
    this.events = new AbortController()
    const { signal } = this.events
    this.element.addEventListener("turbo:before-morph-element", event => this.reset(event), { signal })
    this.element.addEventListener("turbo:morph-element", event => this.render(event), { signal })

    // Wait until widgets in closed dialogs or display:none panels become visible.
    this.observer = new ResizeObserver(() => this.render())
    this.observer.observe(this.element)
    this.render()
  }

  disconnect() {
    this.events.abort()
    this.observer.disconnect()
    this.reset()
  }

  reset(event) {
    // Morph events also bubble from children of this widget.
    if (event && event.target !== this.element) return
    this.pendingRender?.abort()
    if (this.widgetId) window.turnstile?.remove(this.widgetId)
    this.widgetId = null
    this.rendering = false
  }

  async render(event) {
    if (event && event.target !== this.element) return
    if (this.rendering || this.element.getClientRects().length === 0) return
    this.rendering = true
    this.pendingRender = new AbortController()
    const { signal } = this.pendingRender
    const mockResponse = this.element.querySelector('input[name="cf-turnstile-response"][value="mocked"]')
    const turnstile = await (mockResponse ? null : this.turnstileLoaded(signal))

    // A disconnect or morph may have superseded this render while the API loaded.
    if (signal.aborted || !this.element.isConnected) return
    if (this.element.getClientRects().length === 0 || (!mockResponse && !turnstile)) {
      this.rendering = false
      return
    }

    if (mockResponse) {
      // Mock markup already contains its token. Still notify callback-driven forms.
      const callback = this.element.dataset.callback
      if (callback) window[callback](mockResponse.value)
      return
    }

    // Turbo snapshots cannot preserve the widget's shadow root. Start clean.
    this.element.replaceChildren()
    this.widgetId = turnstile.render(this.element)
  }

  turnstileLoaded(signal) {
    if (window.turnstile) return Promise.resolve(window.turnstile)
    const script = document.querySelector('script[src*="challenges.cloudflare.com/turnstile"]')
    if (!script) return Promise.resolve(null)

    return new Promise((resolve) => {
      const finish = () => {
        script.removeEventListener("load", finish)
        script.removeEventListener("error", finish)
        signal.removeEventListener("abort", finish)
        resolve(signal.aborted ? null : window.turnstile)
      }
      script.addEventListener("load", finish, { once: true })
      script.addEventListener("error", finish, { once: true })
      signal.addEventListener("abort", finish, { once: true })
    })
  }
}
```

Every widget needs the controller in explicit mode. Register it as `turnstile` if your Stimulus setup does not automatically load controllers. The morph listeners reset the widget before its children change and render a fresh one afterward, even when Stimulus keeps the same controller connected.

In mock mode, omit `cloudflare_turnstile_script_tag` as shown above: the controller preserves the mock token and invokes `data_callback` once per render, including after Turbo navigation. As with Cloudflare callbacks, define the named function on `window`. Do not also load the mock script with this setup, since it invokes callbacks independently.

`turbo_reload: true` remains the default. Passing `false` only removes the Turbo attributes; it does not install JavaScript or initialize widgets by itself.

## License
The gem is available as open source under the terms of the [ISC License](LICENSE.txt).
