require "spec_helper"
require "user_registered"

RSpec.describe UserRegistered do
  subject{ UserRegistered.new(email: "jack@smith.org", name: "Jack Smith", encrypted_password: "encrypted password") }

  context "#user_slug" do
    it "is auto-generated" do
      expect(subject.user_slug).not_to be_nil
    end
  end
end
