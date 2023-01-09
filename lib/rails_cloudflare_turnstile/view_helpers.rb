# frozen_string_literal: true

module RailsCloudflareTurnstile
  module ViewHelpers
    def cloudflare_turnstile(action: "other")
      return nil unless RailsCloudflareTurnstile.enabled?
      content_tag(:div, class: "cloudflare-turnstile") do
        concat turnstile_div(action)
      end
    end

    def cloudflare_turnstile_script_tag
      return nil unless RailsCloudflareTurnstile.enabled?
      content_tag(:script, :src => js_src, "async" => true) do
        ""
      end
    end

    private

    def turnstile_div(action)
      config = RailsCloudflareTurnstile.configuration
      content_tag(:div, :class => "cf-turnstile", "data-sitekey" => site_key, "data-size" => config.size, "data-action" => action) do
        ""
      end
    end

    def site_key
      RailsCloudflareTurnstile.configuration.site_key
    end

    def js_src
      "https://challenges.cloudflare.com/turnstile/v0/api.js"
    end
  end
end
