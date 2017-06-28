require "dry-struct"
require "securerandom"
require "types"

class BaseEvent < Dry::Struct
  constructor_type :schema

  attribute :event_id,   Types::String.default{ SecureRandom.uuid }
  attribute :created_at, Types::Time.default{ Time.now }
  attribute :request_ip, Types::String
  attribute :user_agent, Types::String
  attribute :session_id, Types::String
end
