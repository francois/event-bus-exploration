require "dry-validation"

module Forms
  ResetPassword = Dry::Validation.Form do
    required(:token).filled(:str?)
    required(:password).filled(:str?, min_size?: 5).confirmation
  end
end
