class UserRegistrationConsumer
  def initialize(users, password_resets)
    @users = users
    @password_resets = password_resets
  end

  def consume_user_registered(event)
    @users.insert(
      email: event.email,
      encrypted_password: event.encrypted_password,
      name: event.name,
    )
  end

  def consume_user_password_change_requested(event)
    @password_resets.insert(
      email: event.email,
      token: event.token,
    )
  end

  def consume_user_password_reset(event)
    @password_resets.filter(token: event.token).delete
    @users.filter(email: event.email).update(encrypted_password: event.new_encrypted_password)
  end
end
