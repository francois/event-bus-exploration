require "dry-validation"

module Forms
  UserRegistration = Dry::Validation.Form do
    required(:email).filled(:str?)
    required(:name).filled(:str?)
    required(:password).filled(:str?, min_size?: 5).confirmation
  end
end
