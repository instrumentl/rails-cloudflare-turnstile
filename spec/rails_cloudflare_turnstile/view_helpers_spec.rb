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

    its(:cloudflare_turnstile_script_tag) { should eq "<script src=\"https://challenges.cloudflare.com/turnstile/v0/api.js\" async=\"async\"></script>" }

    describe "#cloudflare_turnstile" do
      it do
        expect(subject.cloudflare_turnstile(action: "an-action")).to eq "<div class=\"cloudflare-turnstile\"><div class=\"cf-turnstile\" data-sitekey=\"a_public_key\" data-size=\"regular\" data-action=\"an-action\"></div></div>"
      end
    end
  end

  context "configured in mock mode" do
    before do
      RailsCloudflareTurnstile.configure do |c|
        c.enabled = false
        c.mock_enabled = true
      end
    end

    its(:cloudflare_turnstile_script_tag) { should eq nil }

    describe "#cloudflare_turnstile" do
      it do
        expect(subject.cloudflare_turnstile(action: "an-action")).to eq "<div class=\"cloudflare-turnstile\"><div class=\"cf-turnstile\" style=\"width: 300px; height: 65px: border: 1px solid gray\"><p>CAPTCHA goes here in production</p></div></div>"
      end
    end
  end
end
