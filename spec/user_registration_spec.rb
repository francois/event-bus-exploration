require "spec_helper"
require "user_password_change_requested"
require "user_password_reset"
require "user_registered"
require "user_registration_consumer"

RSpec.describe UserRegistrationConsumer do
  let(:consumer) { UserRegistrationConsumer.new(DB[:users], DB[:user_password_change_requests]) }

  describe UserRegistered do
    it "writes to the event to the users table" do
      consumer.consume_user_registered(UserRegistered.new(
        email: "francois@teksol.info",
        encrypted_password: "complex encryption technology",
        name: "François Beausoleil",
      ))

      expect(DB[:users][email: "francois@teksol.info"]).not_to be_nil
    end
  end

  describe UserPasswordChangeRequested do
    before(:each) do
      consumer.consume_user_registered(
        UserRegistered.new(
          email: "john@smith.org",
          name: "John Smith",
          encrypted_password: "john's password",
        )
      )
    end

    it "writes the event to the user_password_change_requests table" do
      consumer.consume_user_password_change_requested(UserPasswordChangeRequested.new(
        email: "john@smith.org",
        token: "a token",
      ))

      expect(DB[:user_password_change_requests][email: "john@smith.org"][:token]).to eq("a token")
    end
  end

  describe UserPasswordReset do
    let(:email) { "jane@smith.org" }
    let(:token) { "some token" }

    let(:user_registered)         { UserRegistered.new(email: email, name: "Jane Smith", encrypted_password: "original") }
    let(:password_change_request) { UserPasswordChangeRequested.new(email: email, token: token) }

    before(:each) do
      consumer.consume_user_registered(user_registered)
      consumer.consume_user_password_change_requested(password_change_request)
    end

    it "replaces the existing encrypted_password on the user with the new_encrypted_password" do
      expect{ consumer.consume_user_password_reset(UserPasswordReset.new(email: email, token: token, new_encrypted_password: "changed")) }.to change{ DB[:users][email: email][:encrypted_password] }.from("original").to("changed")
    end

    it "deletes the one-time password in user_password_change_requests" do
      expect{ consumer.consume_user_password_reset(UserPasswordReset.new(email: email, token: token, new_encrypted_password: "changed")) }.to change{ DB[:user_password_change_requests][email: email] }.to(nil)
    end
  end
end
