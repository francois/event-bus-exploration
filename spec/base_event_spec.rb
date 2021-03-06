require "spec_helper"
require "base_event"

RSpec.describe BaseEvent do
  describe "#event_id" do
    it "is auto-generated" do
      expect(subject.event_id).not_to be_nil
    end
  end

  describe "#created_at" do
    it "defaults to \"now\"" do
      expect((Time.now - 1) .. (Time.now + 1)).to include(subject.created_at)
    end
  end
end
