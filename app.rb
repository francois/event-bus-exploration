require "bundler"
Bundler.require :default, :development

require "dotenv"
Dotenv.load ".env", ".env.development"

require "connections/database"
require "event_bus"
require "pg_event_serializer"
require "user_password_change_requested"
require "user_registered"
require "user_registration_consumer"
require "user_password_reset"

def store
  STORE
end

configure do
  STORE = EventBus.new
  STORE.add_consumer(PGEventStoreConsumer.new(DB[:events]))
  STORE.add_consumer(UserRegistrationConsumer.new(DB[:users], DB[:user_password_change_requests]))

  enable :sessions
end

get "/" do
  erb :home
end

post "/user/request-change-password" do
  event = create_event(UserPasswordChangeRequested,
    email: params[:user][:email],
  )
  store.publish(event)
  redirect "/"
end

post "/user/reset-password" do
  if row = DB[:user_password_change_requests][token: params[:user][:token]]
    event = create_event(UserPasswordReset,
      email: row.fetch(:email),
      token: row.fetch(:token),
      new_encrypted_password: params[:user][:password],
    )

    store.publish(event)
  else
    logger.warn "Failed to find token #{params[:user][:token]}"
  end

  redirect "/"
end

post "/signup" do
  event = create_event(UserRegistered,
    email: params[:user][:email],
    name: params[:user][:name],
    encrypted_password: params[:user][:password].succ,
  )

  store.publish(event)
  redirect "/"
end

helpers do
  def create_event(klass, params)
    klass.new( {request_ip: request.ip, user_agent: request.user_agent, session_id: session.id}.merge(params) )
  end
end
