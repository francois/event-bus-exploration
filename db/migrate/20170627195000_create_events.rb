Sequel.migration do
  change do
    create_table :events do
      column :object_id, :serial, null: false, unique: true
      column :event_id, :uuid, null: false, unique: true
      column :created_at, :timestamptz, null: false
      column :stored_at, :timestamptz, null: false, index: true, default: Sequel.function(:now)
      column :kind, :text, null: false, index: true
      column :payload, :jsonb, null: false
    end
  end
end
