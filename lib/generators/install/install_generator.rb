module RailsCloudflareTurnstile
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def create_initializer
        initializer "cloudflare_turnstile.rb" do
          <<~RUBY
            RailsCloudflareTurnstile.configure do |c|
              # The site key and secret key assuming they are stored in Rails credentials
              # You can also use ENV variables or any other method to store your keys
              c.site_key = Rails.application.credentials.cloudflare_turnstile[:site_key]
              c.secret_key = Rails.application.credentials.cloudflare_turnstile[:secret_key]

              # Only enable the real Turnstile verification in production
              # In development and test, a mock will be used
              c.enabled = Rails.env.production?

              c.fail_open = true
            end
          RUBY
        end
      end

      def add_to_layout
        insert_into_file "app/views/layouts/application.html.erb", before: "</head>" do
          <<~HTML
            <%= cloudflare_turnstile_script_tag %>\n
          HTML
        end
      end
    end
  end
end
