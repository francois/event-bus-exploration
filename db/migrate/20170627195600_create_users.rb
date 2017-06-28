Sequel.migration do
  change do
    create_table :users do
      column :object_id, :serial, null: false, unique: true
      column :email, :text, null: false, primary_key: true
      column :encrypted_password, :text, null: false
      column :name, :text, null: false
    end
  end
end
