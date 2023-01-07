# frozen_string_literal: true

require "spec_helper"
require "action_view"

RSpec.describe RailsCloudflareTurnstile::ViewHelpers do
  subject do
    Class.new do
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper
      include RailsCloudflareTurnstile::ViewHelpers

      attr_accessor :output_buffer
    end.new
  end

  context "not configured" do
    before do
      RailsCloudflareTurnstile.reset_configuration!
    end

    its(:cloudflare_turnstile_script_tag) { should be_nil }
    its(:cloudflare_turnstile) { should be_nil }
  end

  context "configured" do
    let(:site_key) { "a_public_key" }
    let(:secret_key) { "a_secret_key" }

    before do
      RailsCloudflareTurnstile.configure do |c|
        c.site_key = site_key
        c.secret_key = secret_key
      end
    end

    its(:cloudflare_turnstile_script_tag) { should eq "<script src=\"https://challenges.cloudflare.com/turnstile/v0/api.js\" async=\"async\" defer=\"defer\"></script>" }
    its(:cloudflare_turnstile) { should eq "<div class=\"cloudflare-turnstile\"><div class=\"cf-turnstile\" data-sitekey=\"a_public_key\"></div></div>" }
  end
end
