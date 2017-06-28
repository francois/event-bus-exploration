require "bundler/setup"
Bundler.require :test, :default

require "dotenv"
Dotenv.load ".env.test"

require "database_cleaner"
require "rspec"

require "connections/database"

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
