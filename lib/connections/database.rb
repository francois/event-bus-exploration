require "logger"

LOGGER = Logger.new(ENV["RACK_ENV"] == "test" ? "log/test.log" : STDOUT)
LOGGER.level = Logger::DEBUG

def logger
  LOGGER
end

DB = Sequel.connect(ENV.fetch("DATABASE_URL"), logger: logger)
DB.extension :pg_array, :pg_json
