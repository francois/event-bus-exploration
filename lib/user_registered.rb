require "base_event"

class UserRegistered < BaseEvent
  attribute :email,               Types::String
  attribute :encrypted_password,  Types::String
  attribute :name,                Types::String
end
