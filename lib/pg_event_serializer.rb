require "json"

class PGEventStoreConsumer
  def initialize(events)
    @events = events
  end

  def consume(event)
    @events.insert(
      event_id: event.event_id,
      created_at: event.created_at,
      kind: event.class.name,
      payload: stringify_keys(event.to_h).to_json)
  end

  private

  def stringify_keys(hash)
    hash.map do |key, value|
      [key.to_s, value]
    end.to_h
  end
end
