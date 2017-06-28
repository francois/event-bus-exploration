require "base_event"

class UserPasswordChangeRequested < BaseEvent
  attribute :email, Types::String
  attribute :token, Types::String.default{ SecureRandom.urlsafe_base64(64) }
end
