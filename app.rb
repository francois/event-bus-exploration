require "bundler"
Bundler.require :web, :default, :development

begin
  require "dotenv"
  Dotenv.load ".env", ".env.development"
rescue LoadError
  # NOP, running in production
end

require "connections/database"
require "connections/event_bus"
require "forms/request_password_reset_token"
require "forms/user_registration"
require "forms/reset_password"
require "sinatra/base"
require "user_password_change_requested"
require "user_password_reset"
require "user_registered"

class App < Sinatra::Base
  enable :sessions

  def event_bus
    EVENT_BUS
  end

  def repository
    REPOSITORY
  end

  get "/" do
    @token = params[:token]
    erb :home
  end

  post "/signup" do
    form = Forms::UserRegistration.call(params[:user])
    if form.success?
      registration_values =
        form.output.merge(
          encrypted_password: BCrypt::Password.create(form.output[:password]),
          password: nil,
          password_confirmation: nil)

      event = create_event(
        UserRegistered,
        registration_values)

      event_bus.publish(event)
    else
      logger.warn form.errors.inspect
    end

    redirect "/"
  end

  post "/user/request-change-password" do
    form = Forms::RequestPasswordResetToken.call(params[:user])
    if form.success?
      event = create_event(UserPasswordChangeRequested, form.output)
      event_bus.publish(event)
    else
      logger.warn form.errors.inspect
    end

    redirect "/"
  end

  post "/user/reset-password" do
    form = Forms::ResetPassword.call(params[:user])
    if form.success?
      user_password_change_request = repository.find_user_password_change_request_by_token(form.output[:token])
      if user_password_change_request
        password_reset_values = form.output.merge(
          user_id: user_password_change_request.user_id,
          email: user_password_change_request.email,
          token: user_password_change_request.token,
          new_encrypted_password: BCrypt::Password.create(form.output[:password]),
          password: nil,
          password_confirmation: nil)

        event = create_event(UserPasswordReset, password_reset_values)
        event_bus.publish(event)
      else
        logger.warn "Failed to find token #{params[:user][:token]}"
      end
    else
      logger.warn form.errors.inspect
    end

    redirect "/"
  end

  def create_event(klass, params)
    klass.new( {request_ip: request.ip, user_agent: request.user_agent, session_id: session.id}.merge(params) )
  end

  run! if app_file == $0
end
