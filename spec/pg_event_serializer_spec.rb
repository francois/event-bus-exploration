require "pg_event_serializer"
require "repository"
require "spec_helper"
require "user_registered"

RSpec.describe PGEventStoreConsumer do
  let(:repository) { spy(Repository) }
  let(:event) do
    UserRegistered.new(
      email: "francois@teksol.info",
      encrypted_password: "super secret password",
      name: "François Beausoleil",
    )
  end

  subject{ PGEventStoreConsumer.new(repository) }

  describe "#consume" do
    it "delegates to the repository" do
      subject.consume(event)
      expect(repository).to have_received(:create_event).with(event).once
    end
  end
end
