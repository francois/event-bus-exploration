require "bundler/setup"
Bundler.require :test, :default

require "dotenv"
Dotenv.load ".env.test"

require "database_cleaner"
require "logger"
require "rspec"

LOGGER = Logger.new("log/test.log")
LOGGER.level = Logger::DEBUG

def logger
  LOGGER
end

DB = Sequel.connect(ENV.fetch("DATABASE_URL"), logger: logger)
DB.extension :pg_array, :pg_json

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
