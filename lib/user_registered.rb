require "base_event"
require "securerandom"

class UserRegistered < BaseEvent
  attribute :email,               Types::String
  attribute :encrypted_password,  Types::String
  attribute :name,                Types::String
  attribute :user_slug,           Types::String.default{ SecureRandom.urlsafe_base64(8) }
end
