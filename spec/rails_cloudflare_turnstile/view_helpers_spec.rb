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

      def javascript_path(name)
        "/mock/#{name}"
      end

      def image_path(name)
        "/mock/#{name}"
      end

      def image_tag(name)
        "<img src=\"#{image_path name}\" />".html_safe
      end
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

    describe "#cloudflare_turnstile_script_tag" do
      it "should allow overriding async and defer" do
        expect(subject.cloudflare_turnstile_script_tag(async: false, defer: false)).to eq "<script src=\"https://challenges.cloudflare.com/turnstile/v0/api.js\" data-turbo-track=\"reload\" data-turbo-temporary=\"true\"></script>"
        expect(subject.cloudflare_turnstile_script_tag(async: true, defer: false)).to eq "<script src=\"https://challenges.cloudflare.com/turnstile/v0/api.js\" async=\"async\" data-turbo-track=\"reload\" data-turbo-temporary=\"true\"></script>"
        expect(subject.cloudflare_turnstile_script_tag(async: false, defer: true)).to eq "<script src=\"https://challenges.cloudflare.com/turnstile/v0/api.js\" defer=\"defer\" data-turbo-track=\"reload\" data-turbo-temporary=\"true\"></script>"
      end

      it "generates a script tag with async and defer" do
        expect(subject.cloudflare_turnstile_script_tag).to eq "<script src=\"https://challenges.cloudflare.com/turnstile/v0/api.js\" async=\"async\" defer=\"defer\" data-turbo-track=\"reload\" data-turbo-temporary=\"true\"></script>"
      end

      it "should allow using the explicitly rendered version of widget" do
        expect(subject.cloudflare_turnstile_script_tag(explicit: true)).to eq "<script src=\"https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit\" async=\"async\" defer=\"defer\" data-turbo-track=\"reload\" data-turbo-temporary=\"true\"></script>"
      end
    end

    describe "#cloudflare_turnstile" do
      it do
        expect(subject.cloudflare_turnstile(action: "an-action")).to eq "<div class=\"cloudflare-turnstile\"><div class=\"cf-turnstile\" data-sitekey=\"a_public_key\" data-size=\"regular\" data-action=\"an-action\" data-theme=\"auto\"></div></div>"
      end

      it "passes through HTML options" do
        expect(subject.cloudflare_turnstile(action: "an-action", data: {appearance: "interaction-only"})).to eq "<div class=\"cloudflare-turnstile\"><div class=\"cf-turnstile\" data-sitekey=\"a_public_key\" data-size=\"regular\" data-action=\"an-action\" data-theme=\"auto\" data-appearance=\"interaction-only\"></div></div>"
      end

      it "overrides size and theme config through HTML options" do
        expect(subject.cloudflare_turnstile(data: {size: "compact", theme: "light"})).to eq "<div class=\"cloudflare-turnstile\"><div class=\"cf-turnstile\" data-sitekey=\"a_public_key\" data-size=\"compact\" data-action=\"other\" data-theme=\"light\"></div></div>"
      end

      it "passes through container classes" do
        expect(subject.cloudflare_turnstile(container_class: "wrapper")).to eq "<div class=\"cloudflare-turnstile wrapper\"><div class=\"cf-turnstile\" data-sitekey=\"a_public_key\" data-size=\"regular\" data-action=\"other\" data-theme=\"auto\"></div></div>"
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

    its(:cloudflare_turnstile_script_tag) { should eq "<script src=\"/mock/mock_cloudflare_turnstile_api.js\" async=\"async\" defer=\"defer\" data-turbo-track=\"reload\" data-turbo-temporary=\"true\"></script>" }

    describe "#cloudflare_turnstile" do
      it do
        expect(subject.cloudflare_turnstile(action: "an-action")).to eq <<-EOF
          <div class="cloudflare-turnstile">
          <div class="cf-turnstile" style="width: 300px; height: 65px; border: 1px solid gray; display: flex; flex-direction: row; justify-content: center; align-items: center; margin: 10px;">
          <input type="hidden" name="cf-turnstile-response" value="mocked">
          <img src="/mock/turnstile-logo.svg" />
          <p style="margin: 0">CAPTCHA goes here in production</p>
          </div>
          </div>
        EOF
          .gsub(/^\s*/, "")
          .delete "\n"
      end
    end
  end
end
