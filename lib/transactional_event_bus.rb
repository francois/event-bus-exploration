class TransactionalEventBus
  def initialize(db:, event_bus:)
    @db, @event_bus = db, event_bus
  end

  def add_consumer(consumer)
    @event_bus.add_consumer(consumer)
  end

  def publish(event, replay: false)
    @db.transaction do
      @event_bus.publish(event, replay: replay)
    end
  end
end
