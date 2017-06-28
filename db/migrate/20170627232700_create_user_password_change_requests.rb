Sequel.migration do
  change do
    create_table :user_password_change_requests do
      column :email, :text, primary_key: true
      column :token, :text, null: false, unique: true

      foreign_key [:email], :users
    end
  end
end
