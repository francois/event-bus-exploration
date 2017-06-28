class UserRegistrationConsumer
  def initialize(users)
    @users = users
  end

  def consume_user_registered(event)
    @users.insert(
      email: event.email,
      encrypted_password: event.encrypted_password,
      name: event.name,
    )
  end
end
