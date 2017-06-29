class UserRegistrationConsumer
  def initialize(repository)
    @repository = repository
  end

  def consume_user_registered(event)
    @repository.create_user(
      email: event.email,
      encrypted_password: event.encrypted_password,
      name: event.name,
      user_slug: event.user_slug,
    )
  end

  def consume_user_password_change_requested(event)
    @repository.create_user_password_change_request(
      email: event.email,
      token: event.token,
    )
  end

  def consume_user_password_reset(event)
    user_password_change_request = @repository.delete_user_password_change_requests_by_token(event.token)
    @repository.update_user(user_password_change_request.user_id, encrypted_password: event.new_encrypted_password)
  end
end
