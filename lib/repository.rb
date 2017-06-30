require "user"
require "user_password_change_request"

class Repository
  def initialize(db)
    @db = db
  end

  def create_user(attributes)
    @db[:users].insert(attributes)
  end

  def create_user_password_change_request(attributes)
    @db[:user_password_change_requests].insert(attributes)
  end

  # @return UserPasswordChangeRequest
  def delete_user_password_change_requests_by_token(token)
    attributes = @db.from(:user_password_change_requests, :users)
      .returning(:user_password_change_request_id, :user_id, :token, :user_slug)
      .where(users__email: :user_password_change_requests__email) # JOIN condition
      .where(token: token)
      .delete
      .first

    UserPasswordChangeRequest.new(attributes) if attributes
  end

  def update_user(user_id, attributes)
    @db[:users].filter(user_id: user_id).update(attributes)
  end

  def find_user_by_email(email)
    row = @db[:users][email: email]
    User.new(row) if row
  end

  def find_user_password_change_request_by_token(token)
    row = @db[:user_password_change_requests].join(:users, [:email])[token: token]
    UserPasswordChangeRequest.new(row) if row
  end

  def create_event(event)
    @db[:events].insert(
      event_id: event.event_id,
      created_at: event.created_at,
      kind: event.class.name,
      payload: stringify_keys(event.to_h).to_json)
  end

  RecordNotFound = Class.new(StandardError)

  private

  def stringify_keys(hash)
    hash.map do |key, value|
      [key.to_s, value]
    end.to_h
  end
end
