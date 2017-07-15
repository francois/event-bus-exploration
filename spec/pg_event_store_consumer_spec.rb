require "pg_event_store_consumer"
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
    context "when replay: false" do
      it "delegates to the repository" do
        subject.consume(event, replay: false)
        expect(repository).to have_received(:create_event).with(event).once
      end
    end

    context "when replay: true" do
      it "skips delegation to the repository" do
        subject.consume(event, replay: true)
        expect(repository).not_to have_received(:create_event)
      end
    end
  end
end
