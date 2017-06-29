require "repository"
require "spec_helper"

RSpec.describe Repository do
  subject{ Repository.new(DB) }

  describe "#delete_user_password_change_requests_by_token" do
    before(:each) { DB[:users].insert(user_id: 883, email: "jaden@smith.org", name: "Jaden", user_slug: "jjj", encrypted_password: "password") }
    before(:each) { DB[:user_password_change_requests].insert(user_password_change_request_id: 111, email: "jaden@smith.org", token: "yyy") }

    it "leaves another user_password_change_request record alone" do
      DB[:users].insert(user_id: 884, email: "sarah@smith.org", name: "Sarah", user_slug: "asdfa", encrypted_password: "password")
      DB[:user_password_change_requests].insert(user_password_change_request_id: 112, email: "sarah@smith.org", token: "hdhdf")

      subject.delete_user_password_change_requests_by_token("yyy")

      expect(DB[:user_password_change_requests][user_password_change_request_id: 112].to_a).not_to be_empty
    end

    it "deletes the user_password_change_request record" do
      subject.delete_user_password_change_requests_by_token("yyy")
      expect(DB[:user_password_change_requests][user_password_change_request_id: 111].to_a).to be_empty
    end

    it "leaves the user record alone" do
      subject.delete_user_password_change_requests_by_token("yyy")
      expect(DB[:users][user_id: 883].to_a).not_to be_empty
    end

    it "returns a UserPasswordChangeRequest instance" do
      request = subject.delete_user_password_change_requests_by_token("yyy")
    end
  end

  describe "#find_user_by_email" do
    context "when the database is empty" do
      it{ expect(subject.find_user_by_email("no@where.com")).to be_nil }
    end

    context "when the database contains a row with email == jones@smith.org" do
      before(:each) do
        DB[:users].insert(
          name: "Jones Smith",
          email: "jones@smith.org",
          encrypted_password: "password",
          user_slug: "bbb")
      end

      it "finds the row when requesting jones@smith.org" do
        expect(subject.find_user_by_email("jones@smith.org")).not_to be_nil
      end

      it "returns nil when requesting an email address that doesn't exist" do
        expect(subject.find_user_by_email("jack@smith.org")).to be_nil
      end
    end
  end

  describe "#find_user_password_change_request_by_token" do
    before(:each) do
      DB[:users].insert(
        user_id: 1412,
        name: "Jill Smith",
        email: "jill@smith.org",
        encrypted_password: "password",
        user_slug: "aaa")
    end

    before(:each) { DB[:user_password_change_requests].insert(email: "jill@smith.org", token: "12345") }

    it "returns the email address" do
      request = subject.find_user_password_change_request_by_token("12345")
      expect(request.user_id).to eq(1412)
      expect(request.token).to eq("12345")
    end
  end

  describe "#create_event" do
    it "stores the event's class in the kind column" do
      expect{ subject.create_event(UserPasswordChangeRequested.new(email: "sarah@smith.org")) }.to change{ DB[:events].count }.from(0).to(1)
      expect(DB[:events].first.fetch(:kind)).to eq(UserPasswordChangeRequested.name)
    end

    it "stores the JSON representation of the event's attributes in the payload column" do
      event = UserRegistered.new(email: "francois@teksol.info", name: "François Beausoleil", encrypted_password: "super secret password") 
      subject.create_event(event)
      payload = DB[:events].first.fetch(:payload)
      expect(payload).not_to be_nil
      expect(payload["name"]).to eq("François Beausoleil")
      expect(payload["email"]).to eq("francois@teksol.info")
      expect(payload["encrypted_password"]).to eq("super secret password")
      expect(payload["user_slug"]).to eq(event.user_slug)
    end
  end
end
