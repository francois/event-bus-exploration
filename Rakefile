require "dotenv/tasks"

namespace :db do
  task :migrate => :dotenv do
    sh "sequel --echo --migrate-directory db/migrate #{ENV.fetch("DATABASE_URL")}"
  end
end
