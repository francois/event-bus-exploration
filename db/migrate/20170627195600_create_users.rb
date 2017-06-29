Sequel.migration do
  change do
    create_table :users do
      column :object_id, :serial, null: false, unique: true
      column :user_id, :serial, null: false, primary_key: true
      column :email, :text, null: false, unique: true
      column :encrypted_password, :text, null: false
      column :name, :text, null: false
      column :user_slug, :text, null: false, unique: true
    end
  end
end
