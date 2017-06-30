source "https://rubygems.org"
ruby "2.4.0"

gem "bcrypt"
gem "dry-struct"
gem "dry-types"
gem "pg"
gem "rake"
gem "sequel"
gem "sequel_pg", require: false

group :web do
  gem "dry-validation"
  gem "sinatra", require: false
end

group :notifiers do
  gem "mail"
end

group :development, :test do
  gem "byebug"
  gem "database_cleaner"
  gem "dotenv"
  gem "rspec"
end
