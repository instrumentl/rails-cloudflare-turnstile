# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsCloudflareTurnstile do
  describe "VERSION" do
    it "exists" do
      expect(RailsCloudflareTurnstile::VERSION).not_to be_nil
    end
  end

  describe "configuration" do
    around do |example|
      described_class.reset_configuration!
      example.run
      described_class.reset_configuration!
    end

    it "raises if stuff is unset" do
      expect {
        described_class.configure
      }.to raise_error(RuntimeError)
      expect(described_class.enabled?).to be false
    end

    it "does not raise if disabled, even if nothing else is set" do
      described_class.configure do |c|
        c.site_key = nil
        c.enabled = false
      end
      expect(described_class.enabled?).to be false
    end

    it "does not raise if everything is set" do
      described_class.configure do |c|
        c.site_key = "abc"
        c.secret_key = "secret"
      end
      expect(described_class.enabled?).to be true
    end
  end
end
