require "base_event"

class UserPasswordReset < BaseEvent
  attribute :user_id, Types::Int
  attribute :email, Types::String
  attribute :token, Types::String
  attribute :new_encrypted_password, Types::String
end
