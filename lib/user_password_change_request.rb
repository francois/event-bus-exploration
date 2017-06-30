require "dry-struct"
require "types"

class UserPasswordChangeRequest < Dry::Struct
  attribute :user_password_change_request_id, Types::Int
  attribute :user_id, Types::Int
  attribute :email, Types::String
  attribute :token, Types::String
  attribute :user_slug, Types::String
end
