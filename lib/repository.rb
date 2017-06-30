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
  def get_welcome_email_worker_state
    get_worker_state(UserRegistered.name)
  end

  def find_user_registration_events_after(sequence)
    find_named_events_after(UserRegistered, sequence)
  end

  # @return [Void]
  def set_welcome_email_worker_state(sequence)
    set_worker_state(UserRegistered.name, sequence)
  end

  # @return [Integer] The last seen event sequence for UserPasswordChangeRequested events.
  def get_password_reset_requests_worker_state
    get_worker_state(UserPasswordChangeRequested.name)
  end

  def find_user_password_change_requests_after(sequence)
    find_named_events_after(UserPasswordChangeRequested, sequence)
  end

  # @return [Void]
  def set_password_reset_requests_worker_state(sequence)
    set_worker_state(UserPasswordChangeRequested.name, sequence)
  end

  # @return [Integer] The last seen event sequence for UserPasswordReset events.
  def get_password_resets_worker_state
    get_worker_state(UserPasswordReset.name)
  end

  def find_user_password_resets_after(sequence)
    find_named_events_after(UserPasswordReset, sequence)
  end

  # @return [Void]
  def set_password_resets_worker_state(sequence)
    set_worker_state(UserPasswordReset.name, sequence)
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

  def get_worker_state(name)
    @db[:worker_states]
      .filter(name: name)
      .select_map(:last_seen_sequence)
      .first || 0
  end

  def set_worker_state(name, sequence)
    sql = @db[<<-EOSQL.gsub(/^ {6}/, "").chomp, name: name, sequence: sequence].sql
      WITH updates AS (
        UPDATE worker_states
        SET last_seen_sequence = :sequence, updated_at = current_timestamp
        RETURNING name, last_seen_sequence, updated_at)

      INSERT INTO worker_states(name, last_seen_sequence, updated_at)
        SELECT :name, :sequence, current_timestamp
        EXCEPT
        SELECT name, last_seen_sequence, updated_at FROM updates
    EOSQL

    @db.run sql
    nil
  end

  def find_named_events_after(klass, sequence)
    @db[:events]
      .filter(kind: klass.name)
      .filter("seq > ?", sequence)
      .map{|row| [row.fetch(:seq), klass.new(symbolize_keys(row.fetch(:payload)))]}
      .to_h
  end
end
