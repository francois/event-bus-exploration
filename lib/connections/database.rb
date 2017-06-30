require "logger"
require "repository"
require "sequel"

LOGGER = Logger.new(ENV["RACK_ENV"] == "test" ? "log/test.log" : STDERR)
LOGGER.level = Logger::DEBUG
LOGGER.formatter = ->(severity, _, _, msg) do
  "[#{"%-5s" % severity}] #{File.basename($0)}:#{Process.pid} - #{msg}\n"
end

def logger
  LOGGER
end

DB = Sequel.connect(ENV.fetch("DATABASE_URL"), logger: logger)
DB.extension :auto_literal_strings
DB.extension :pg_array, :pg_json

# Enable :a__b => "a"."b"
Sequel.split_symbols = true

REPOSITORY = Repository.new(DB)
