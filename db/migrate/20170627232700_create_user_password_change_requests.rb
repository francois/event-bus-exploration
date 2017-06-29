Sequel.migration do
  change do
    create_table :user_password_change_requests do
      column :object_id, :serial, unique: true
      column :user_password_change_request_id, :serial, primary_key: true
      column :email, :text, unique: true
      column :token, :text, null: false, unique: true

      foreign_key [:email], :users, key: :email, on_update: :cascade, on_delete: :cascade
    end
  end
end
