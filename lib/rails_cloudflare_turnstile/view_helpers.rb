# frozen_string_literal: true

module RailsCloudflareTurnstile
  module ViewHelpers
    def cloudflare_turnstile(action: "other", data_callback: nil)
      if RailsCloudflareTurnstile.enabled?
        content_tag(:div, class: "cloudflare-turnstile") do
          concat turnstile_div(action, data_callback: data_callback)
        end
      elsif RailsCloudflareTurnstile.mock_enabled?
        content_tag(:div, class: "cloudflare-turnstile") do
          concat mock_turnstile_div(action, data_callback: data_callback)
        end
      end
    end

    def cloudflare_turnstile_script_tag(async: true, defer: true)
      if RailsCloudflareTurnstile.enabled?
        content_tag(:script, src: js_src, async: async, defer: defer) do
          ""
        end
      elsif RailsCloudflareTurnstile.mock_enabled?
        content_tag(:script, src: mock_js, async: async, defer: defer) do
          ""
        end
      end
    end

    private

    def turnstile_div(action, data_callback: nil)
      config = RailsCloudflareTurnstile.configuration
      content_tag(:div, :class => "cf-turnstile", "data-sitekey" => site_key, "data-size" => config.size, "data-action" => action, "data-callback" => data_callback, "data-theme" => config.theme) do
        ""
      end
    end

    def mock_turnstile_div(action, data_callback: nil)
      content_tag(:div, :class => "cf-turnstile", :style => "width: 300px; height: 65px; border: 1px solid gray; display: flex; flex-direction: row; justify-content: center; align-items: center; margin: 10px;", "data-callback" => data_callback) do
        [
          tag.input(type: "hidden", name: "cf-turnstile-response", value: "mocked"),
          image_tag("turnstile-logo.svg"),
          content_tag(:p, style: "margin: 0") do
            "CAPTCHA goes here in production"
          end
        ].reduce(:<<)
      end
    end

    def site_key
      RailsCloudflareTurnstile.configuration.site_key
    end

    def js_src
      "https://challenges.cloudflare.com/turnstile/v0/api.js"
    end

    def mock_js
      javascript_path "mock_cloudflare_turnstile_api.js"
    end
  end
end
