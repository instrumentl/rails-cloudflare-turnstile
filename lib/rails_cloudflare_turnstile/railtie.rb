module RailsCloudflareTurnstile
  class Railtie < ::Rails::Railtie
    initializer "rails_cloudflare_turnstile" do |app|
      ActiveSupport.on_load(:action_controller) do
        include RailsCloudflareTurnstile::ControllerHelpers
      end

      ActiveSupport.on_load(:action_view) do
        include RailsCloudflareTurnstile::ViewHelpers
      end

      app.config.assets.precompile += %w[mock_cloudflare_turnstile_api.js turnstile-logo.svg]
    end
  end
end
