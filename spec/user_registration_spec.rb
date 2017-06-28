require "event_bus"
require "spec_helper"
require "user_registered"
require "user_registration_consumer"

RSpec.describe "user registration" do
  let(:store)    { EventBus.new }
  let(:consumer) { UserRegistrationConsumer.new(DB[:users]) }
  before(:each)  { store.add_consumer(consumer) }

  it "writes to the event to the users table" do
    store.publish(UserRegistered.new(
      email: "francois@teksol.info",
      encrypted_password: "complex encryption technology",
      name: "François Beausoleil",
    ))

    expect(DB[:users][email: "francois@teksol.info"]).not_to be_nil
  end
end
