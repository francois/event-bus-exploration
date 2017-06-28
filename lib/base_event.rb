require "dry-struct"
require "securerandom"
require "types"

class BaseEvent < Dry::Struct
  constructor_type :strict_with_defaults

  attribute :event_id,   Types::String.default{ SecureRandom.uuid }
  attribute :created_at, Types::Time.default{ Time.now }
end
