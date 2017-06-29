require "dry-struct"
require "types"

class User < Dry::Struct
  attribute :user_id,             Types::Int
  attribute :email,               Types::String
  attribute :name,                Types::String
  attribute :encrypted_password,  Types::String
  attribute :user_slug,           Types::String

  alias_method :id, :user_id
  alias_method :slug, :user_slug
end
