require "spec_helper"
require "user_password_change_requested"

RSpec.describe UserPasswordChangeRequested do
  subject{ UserPasswordChangeRequested.new(email: "jane@smith.org") }

  describe "#token" do
    it "is auto-generated" do
      expect(subject.token).not_to be_nil
    end
  end
end
