Sequel.migration do
  change do
    create_table :worker_states do
      column :name, :text, primary_key: true
      column :last_seen_sequence, :int, null: false
      column :updated_at, :timestamptz, null: false
    end
  end
end
