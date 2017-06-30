require "user"
require "user_password_change_request"
require "user_password_change_requested"

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
      .returning(:user_password_change_request_id, :users__email, :user_id, :token, :user_slug)
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
    row = @db[:user_password_change_requests]
      .join(:users, [:email])[token: token]
    UserPasswordChangeRequest.new(row) if row
  end

  # @return [Integer] The last seen event sequence for UserPasswordChangeRequested events.
  def get_password_reset_requests_worker_state
    @db[:reset_password_requests_worker_state]
      .select_map(:last_seen_sequence)
      .first || 0
  end

  # @return [Void]
  def set_password_reset_requests_worker_state(sequence)
    sql = @db[<<-EOSQL.gsub(/^ {6}/, "").chomp, sequence: sequence].sql
      WITH updates AS (
        UPDATE reset_password_requests_worker_state
        SET last_seen_sequence = :sequence, updated_at = current_timestamp
        RETURNING last_seen_sequence, updated_at)

      INSERT INTO reset_password_requests_worker_state(last_seen_sequence, updated_at)
        SELECT :sequence, current_timestamp
        EXCEPT
        SELECT last_seen_sequence, updated_at FROM updates
    EOSQL

    @db.run sql
    nil
  end

  # @return [Integer] The last seen event sequence for UserPasswordReset events.
  def get_password_resets_worker_state
    @db[:reset_password_worker_state]
      .select_map(:last_seen_sequence)
      .first || 0
  end

  # @return [Void]
  def set_password_resets_worker_state(sequence)
    sql = @db[<<-EOSQL.gsub(/^ {6}/, "").chomp, sequence: sequence].sql
      WITH updates AS (
        UPDATE reset_password_worker_state
        SET last_seen_sequence = :sequence, updated_at = current_timestamp
        RETURNING last_seen_sequence, updated_at)

      INSERT INTO reset_password_worker_state(last_seen_sequence, updated_at)
        SELECT :sequence, current_timestamp
        EXCEPT
        SELECT last_seen_sequence, updated_at FROM updates
    EOSQL

    @db.run sql
    nil
  end

  def find_user_password_change_requests_after(seq)
    @db[:events]
      .filter("seq > ?", seq)
      .filter(kind: UserPasswordChangeRequested.name)
      .map{|attrs| [attrs.fetch(:seq), UserPasswordChangeRequested.new(symbolize_keys(attrs.fetch(:payload)))]}
      .to_h
  end

  def find_user_password_resets_after(seq)
    @db[:events]
      .filter("seq > ?", seq)
      .filter(kind: UserPasswordReset.name)
      .map{|attrs| [attrs.fetch(:seq), UserPasswordReset.new(symbolize_keys(attrs.fetch(:payload)))]}
      .to_h
  end

  def create_event(event)
    @db[:events].insert(
      event_id: event.event_id,
      created_at: event.created_at,
      kind: event.class.name,
      payload: stringify_keys(event.to_h).to_json)
    @db.run @db["NOTIFY #{event.class.name.inspect}"].sql
  end

  RecordNotFound = Class.new(StandardError)

  private

  def stringify_keys(hash)
    hash.map do |key, value|
      [key.to_s, value]
    end.to_h
  end

  def symbolize_keys(hash)
    hash.map do |key, value|
      [key.to_sym, value]
    end.to_h
  end
end
