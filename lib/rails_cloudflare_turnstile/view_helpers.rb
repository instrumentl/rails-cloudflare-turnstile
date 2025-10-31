# frozen_string_literal: true

module RailsCloudflareTurnstile
  module ViewHelpers
    def cloudflare_turnstile(action: "other", data_callback: nil, container_class: nil, **html_options)
      container_class = ["cloudflare-turnstile", container_class].compact.join(" ")

      if RailsCloudflareTurnstile.enabled?
        content_tag(:div, class: container_class) do
          concat turnstile_div(action, data_callback: data_callback, **html_options)
        end
      elsif RailsCloudflareTurnstile.mock_enabled?
        content_tag(:div, class: container_class) do
          concat mock_turnstile_div(action, data_callback: data_callback, **html_options)
        end
      end
    end

    def cloudflare_turnstile_script_tag(async: true, defer: true, explicit: false)
      if RailsCloudflareTurnstile.enabled?
        content_tag(:script, src: js_src(explicit:), async: async, defer: defer, data: {turbo_track: "reload", turbo_temporary: true}) do
          ""
        end
      elsif RailsCloudflareTurnstile.mock_enabled?
        content_tag(:script, src: mock_js, async: async, defer: defer, data: {turbo_track: "reload", turbo_temporary: true}) do
          ""
        end
      end
    end

    private

    def turnstile_div(action, data_callback: nil, **html_options)
      config = RailsCloudflareTurnstile.configuration
      data = html_options[:data] || {}
      size = data[:size] || config.size
      theme = data[:theme] || config.theme

      if html_options[:data]
        html_options[:data] = html_options[:data].except(:size, :theme)
        html_options.delete(:data) if html_options[:data].empty?
      end

      content_tag(:div, :class => "cf-turnstile", "data-sitekey" => site_key, "data-size" => size, "data-action" => action, "data-callback" => data_callback, "data-theme" => theme, **html_options) do
        ""
      end
    end

    def mock_turnstile_div(action, data_callback: nil, **html_options)
      content_tag(:div, :class => "cf-turnstile", :style => "width: 300px; height: 65px; border: 1px solid gray; display: flex; flex-direction: row; justify-content: center; align-items: center; margin: 10px;", "data-callback" => data_callback, **html_options) do
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

    def js_src(explicit: false)
      if explicit
        "https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit"
      else
        "https://challenges.cloudflare.com/turnstile/v0/api.js"
      end
    end

    def mock_js
      javascript_path "mock_cloudflare_turnstile_api.js"
    end
  end
end
