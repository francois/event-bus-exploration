Sequel.migration do
  change do
    create_table :reset_password_requests_worker_state do
      column :last_seen_sequence, :int, primary_key: true
      column :updated_at, :timestamptz, null: false
    end

    create_table :reset_password_worker_state do
      column :last_seen_sequence, :int, primary_key: true
      column :updated_at, :timestamptz, null: false
    end
  end
end
