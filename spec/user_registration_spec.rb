require "repository"
require "spec_helper"
require "user_password_change_requested"
require "user_password_reset"
require "user_registered"
require "user_registration_consumer"

RSpec.describe UserRegistrationConsumer do
  let(:repository) { spy(Repository) }
  subject { UserRegistrationConsumer.new(repository) }

  describe UserRegistered do
    it "delegates writing the user to the repository" do
      event = UserRegistered.new(
        email: "francois@teksol.info",
        encrypted_password: "complex encryption technology",
        name: "François Beausoleil",
      )

      subject.consume_user_registered(event)

      expect(repository).to have_received(:create_user).with(
        email: "francois@teksol.info",
        name: "François Beausoleil",
        encrypted_password: "complex encryption technology",
        user_slug: event.user_slug).once
    end
  end

  describe UserPasswordChangeRequested do
    it "delegates writing the user password change to the repository" do
      event = UserPasswordChangeRequested.new(
        email: "john@smith.org",
        token: "a token",
      )
      subject.consume_user_password_change_requested(event)

      expect(repository).to have_received(:create_user_password_change_request).with(
        email: "john@smith.org",
        token: "a token",
      ).once
    end
  end

  describe UserPasswordReset do
    let(:user_id) { 2334 }
    let(:email)   { "jane@smith.org" }
    let(:token)   { "some token" }

    let(:user_password_reset) { UserPasswordReset.new(user_id: user_id, token: token, new_encrypted_password: "new password") }

    it "deletes the password change request with the token" do
      subject.consume_user_password_reset(user_password_reset)
      expect(repository).to have_received(:delete_user_password_change_requests_by_token).with(token).once
    end

    it "changes the updates the user's password" do
      allow(repository).to receive(:delete_user_password_change_requests_by_token).
        and_return(UserPasswordChangeRequest.new(
          user_password_change_request_id: 203,
          email: email,
          user_id: user_id,
          token: token,
          user_slug: "dg",
      ))

      subject.consume_user_password_reset(user_password_reset)
      expect(repository).to have_received(:update_user).with(user_id, encrypted_password: "new password").once
    end
  end
end
