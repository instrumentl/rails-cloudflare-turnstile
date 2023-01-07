require "rails_cloudflare_turnstile/version"
require "rails_cloudflare_turnstile/configuration"
require "rails_cloudflare_turnstile/errors"
require "rails_cloudflare_turnstile/controller_helpers"
require "rails_cloudflare_turnstile/view_helpers"
require "rails_cloudflare_turnstile/railtie"

module RailsCloudflareTurnstile
  LOCK = Mutex.new

  def self.configure
    yield(configuration) if block_given?
    unless configuration.disabled?
      configuration.validate!
    end
    if configuration.enabled.nil?
      configuration.enabled = true
    else
    end
  end

  def self.enabled?
    configuration.enabled == true
  end

  def self.reset_configuration!
    LOCK.synchronize do
      @configuration = nil
    end
  end

  def self.configuration
    @configuration = nil unless defined?(@configuration)
    @configuration || LOCK.synchronize { @configuration ||= RailsCloudflareTurnstile::Configuration.new }
  end
end
