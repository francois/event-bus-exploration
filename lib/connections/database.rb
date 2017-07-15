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

database_url = ENV.fetch("DATABASE_URL")
raise ArgumentError, "This application requires a PostgreSQL database instance; found #{database_url}}" unless database_url[/^postgres/]
DB = Sequel.connect(database_url, logger: logger)
version = DB["SELECT version()"].select_map(:version).first
raise ArgumentError, "This application requires a PostgreSQL 9.6+ cluster; found #{version}" unless version[/^PostgreSQL (?:10[.]|9[.]6)/]
DB.extension :auto_literal_strings
DB.extension :pg_array, :pg_json

# Enable :a__b => "a"."b"
Sequel.split_symbols = true

REPOSITORY = Repository.new(DB)
