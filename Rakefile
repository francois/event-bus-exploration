require "uri"

begin
  require "dotenv/tasks"
rescue LoadError
  # NOP: we're in production
  task :dotenv do
    # NOP
  end
end

namespace :db do
  task :migrate => :dotenv do
    sh "sequel --echo --migrate-directory db/migrate #{ENV.fetch("DATABASE_URL")}"
  end

  task :reset => :dotenv do
    uri = URI.parse(ENV.fetch("DATABASE_URL"))
    dbname = uri.path[1..-1]
    sh "( dropdb #{dbname} 2>/dev/null || exit 0 ) && createdb #{dbname}"
    Rake::Task["db:migrate"].invoke
  end
end

task :spec do
  sh "rspec"
end

task :default => :spec
