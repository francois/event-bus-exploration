require "bundler"
Bundler.require :default, :development

require "dotenv"
Dotenv.load ".env", ".env.development"

require "connections/database"
require "event_bus"
require "pg_event_serializer"
require "transactional_event_bus"
require "user_password_change_requested"
require "user_password_reset"
require "user_registered"
require "user_registration_consumer"

def event_bus
  EVENT_BUS
end

def repository
  REPOSITORY
end

configure do
  EVENT_BUS = TransactionalEventBus.new(event_bus: EventBus.new, db: DB)
  EVENT_BUS.add_consumer(PGEventStoreConsumer.new(repository))
  EVENT_BUS.add_consumer(UserRegistrationConsumer.new(repository))

  enable :sessions
end

get "/" do
  erb :home
end

post "/signup" do
  event = create_event(UserRegistered,
    email: params[:user][:email],
    name: params[:user][:name],
    encrypted_password: params[:user][:password].succ,
  )

  event_bus.publish(event)
  redirect "/"
end

post "/user/request-change-password" do
  event = create_event(UserPasswordChangeRequested,
    email: params[:user][:email],
  )
  event_bus.publish(event)
  redirect "/"
end

post "/user/reset-password" do
  user_password_change_request = repository.find_user_password_change_request_by_token(params[:user][:token])
  if user_password_change_request
    event = create_event(UserPasswordReset,
                         user_id: user_password_change_request.user_id,
                         token: user_password_change_request.token,
                         new_encrypted_password: params[:user][:password],
    )

    event_bus.publish(event)
  else
    logger.warn "Failed to find token #{params[:user][:token]}"
  end

  redirect "/"
end

helpers do
  def create_event(klass, params)
    klass.new( {request_ip: request.ip, user_agent: request.user_agent, session_id: session.id}.merge(params) )
  end
end
