module RailsCloudflareTurnstile
  class Railtie < ::Rails::Railtie
    initializer "rails_cloudflare_turnstile" do
      ActiveSupport.on_load(:action_controller) do
        include RailsCloudflareTurnstile::ControllerHelpers
      end

      ActiveSupport.on_load(:action_view) do
        include RailsCloudflareTurnstile::ViewHelpers
      end
    end
  end
end
