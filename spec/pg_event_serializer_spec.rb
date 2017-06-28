require "pg_event_serializer"
require "spec_helper"
require "user_registered"

RSpec.describe PGEventStoreConsumer do
  let(:event) do
    UserRegistered.new(
      email: "francois@teksol.info",
      encrypted_password: "super secret password",
      name: "François Beausoleil",
    )
  end

  subject{ PGEventStoreConsumer.new(DB[:events]) }

  describe "#consume" do
    before(:each) { subject.consume(event) }

    it "stores the event to the events table" do
      expect(DB[:events].first.fetch(:kind)).to eq(UserRegistered.name)
    end

    it "stores the JSON representation of the event's attributes in the payload column" do
      payload = DB[:events].first.fetch(:payload)
      expect(payload).not_to be_nil
      expect(payload["name"]).to eq("François Beausoleil")
      expect(payload["email"]).to eq("francois@teksol.info")
      expect(payload["encrypted_password"]).to eq("super secret password")
    end
  end
end
