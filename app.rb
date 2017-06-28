require "bundler"
Bundler.require :default, :development

require "dotenv"
Dotenv.load ".env", ".env.development"

require "event_store"
require "pg_event_serializer"
require "user_registered"
require "user_registration_consumer"

def logger
  LOGGER
end

def store
  STORE
end

configure do
  LOGGER = Logger.new("log/test.log")
  LOGGER.level = Logger::DEBUG

  DB = Sequel.connect(ENV.fetch("DATABASE_URL"), logger: logger)
  DB.extension :pg_array, :pg_json

  STORE = EventStore.new
  STORE.add_consumer(PGEventStoreConsumer.new(DB[:events]))
  STORE.add_consumer(UserRegistrationConsumer.new(DB[:users]))
end

get "/" do
  erb :home
end

post "/signup" do
  event = UserRegistered.new(
    :email              => params[:user][:email],
    :name               => params[:user][:name],
    :encrypted_password => params[:user][:password].succ,
  )

  store.publish(event)
  redirect "/"
end
