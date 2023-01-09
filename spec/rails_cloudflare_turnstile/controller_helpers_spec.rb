# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsCloudflareTurnstile::ControllerHelpers do
  let(:env) { {"REMOTE_ADDR" => "127.0.0.1"} }
  let(:cf_response) { "foo" }
  let(:params) { {"cf-turnstile-response" => cf_response} }
  let(:request) { ActionDispatch::Request.new(env) }

  subject do
    Class.new do
      include RailsCloudflareTurnstile::ControllerHelpers

      attr_reader :params, :request

      def initialize(params, request)
        @params = params
        @request = request
      end
    end.new(params, request)
  end

  describe "#validate_cloudflare_turnstile" do
    it "returns nil when ok" do
      expect(subject).to receive(:cloudflare_turnstile_ok?).and_return(true)
      expect(subject.send(:validate_cloudflare_turnstile)).to eq nil
    end

    it "raises an error" do
      expect(subject).to receive(:cloudflare_turnstile_ok?).and_return(false)
      expect {
        subject.send(:validate_cloudflare_turnstile)
      }.to raise_error(RailsCloudflareTurnstile::Forbidden)
    end
  end

  describe "#cloudflare_turnstile_ok?" do
    context "not configured" do
      before do
        RailsCloudflareTurnstile.reset_configuration!
      end

      its(:cloudflare_turnstile_ok?) { should eq true }
    end

    context "configured" do
      let(:site_key) { "a_public_key" }
      let(:secret_key) { "a_secret_key" }
      let(:fail_open) { true }
      let(:logger) { double("logger") }

      before do
        RailsCloudflareTurnstile.configure do |c|
          c.site_key = site_key
          c.secret_key = secret_key
          c.fail_open = fail_open
        end
        allow(Rails).to receive(:logger).and_return(logger)
        allow(logger).to receive(:error)
      end

      context "response from cloudflare" do
        around do |example|
          s = stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify")
            .with(body: {secret: secret_key, response: cf_response, remoteip: "127.0.0.1"})
            .to_return(status: 200, body: JSON.dump(response), headers: {"Content-Type" => "application/json"})
          example.run
          expect(s).to have_been_requested
        end

        context "passes" do
          let(:response) do
            {
              "success" => true,
              "challenge_ts" => Time.now.strftime("%Y-%m-%dT%H:%M:%SZ"),
              "hostname" => "example.com",
              "error-codes" => [],
              "action" => "login",
              "cdata" => "ignored"
            }
          end

          its(:cloudflare_turnstile_ok?) { should eq true }
        end

        context "fails" do
          let(:response) do
            {
              "success" => false,
              "challenge_ts" => Time.now.strftime("%Y-%m-%dT%H:%M:%SZ"),
              "hostname" => "example.com",
              "error-codes" => ["bad-request"],
              "action" => "login",
              "cdata" => "ignored"
            }
          end
          its(:cloudflare_turnstile_ok?) { should eq false }
        end
      end

      context "timeout" do
        around do |example|
          s = stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify")
            .with(body: {secret: secret_key, response: cf_response, remoteip: "127.0.0.1"})
            .to_timeout
          example.run
          expect(s).to have_been_requested
        end

        context "fail_open = true" do
          let(:fail_open) { true }

          its(:cloudflare_turnstile_ok?) { should eq true }
        end

        context "fail_open = false" do
          let(:fail_open) { false }

          its(:cloudflare_turnstile_ok?) { should eq false }
        end
      end
    end
  end
end
