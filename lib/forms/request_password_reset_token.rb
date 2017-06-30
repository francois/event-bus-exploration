require "dry-validation"

module Forms
  RequestPasswordResetToken = Dry::Validation.Form do
    required(:email).filled(:str?)
  end
end
