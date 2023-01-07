module RailsCloudflareTurnstile
  class Configuration
    # site key (your public key)
    attr_accessor :site_key

    # secret key
    attr_accessor :secret_key

    # if true, then a failure to contact cloudflare will allow all requests
    # if false, then a failure to contact cloudflare will block all requests
    # defaults to true
    attr_accessor :fail_open

    attr_accessor :validation_url

    # Timeout for operations with Cloudflare
    attr_accessor :timeout

    # size for the widget ("regular" or "compact")
    attr_accessor :size

    attr_accessor :enabled

    def initialize
      @site_key = nil
      @secret_key = nil
      @fail_open = true
      @enabled = nil
      @timeout = 5.0
      @size = :regular
      @validation_url = "https://challenges.cloudflare.com/turnstile/v0/siteverify"
    end

    def validate!
      raise "Must set site key" if @site_key.nil?
      raise "Must set secret key" if @secret_key.nil?
      @size = @size.to_sym
      raise "Size must be one of ':regular' or ':compact'" unless [:regular, :compact].include? @size
    end

    def disabled?
      @enabled == false
    end
  end
end
