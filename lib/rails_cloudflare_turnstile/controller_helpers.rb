# frozen_string_literal: true

require "faraday"

module RailsCloudflareTurnstile
  module ControllerHelpers
    def cloudflare_turnstile_ok?
      return true unless RailsCloudflareTurnstile.enabled?

      config = RailsCloudflareTurnstile.configuration

      url = URI(config.validation_url)

      body = {
        secret: config.secret_key,
        response: params["cf-turnstile-response"],
        remoteip: request.remote_ip
      }

      begin
        resp = Faraday.new(url) { |conn|
          conn.options.timeout = config.timeout
          conn.options.open_timeout = config.timeout
          conn.use Faraday::Response::RaiseError
          conn.request :json
          conn.response :json
        }.post(url, body)
      rescue Faraday::Error => e
        Rails.logger.error "Error response from CloudFlare Turnstile: #{e}"
        if config.fail_open
          return true
        else
          return false
        end
      end

      json = resp.body

      success = json["success"]

      return true if success

      error = json["error-codes"][0]

      ActiveSupport::Notifications.instrument(
        "rails_cloudflare_turnstile.failure",
        message: error,
        remote_ip: request.remote_ip,
        user_agent: request.user_agent,
        controller: params[:controller],
        action: params[:action],
        url: request.url
      )

      false
    end

    private

    def validate_cloudflare_turnstile
      return if cloudflare_turnstile_ok?
      raise RailsCloudflareTurnstile::Forbidden
    end
  end
end
