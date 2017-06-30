class TransactionalEventBus
  def initialize(db:, event_bus:)
    @db, @event_bus = db, event_bus
  end

  def add_consumer(consumer)
    @event_bus.add_consumer(consumer)
  end

  def publish(event)
    @db.transaction do
      @event_bus.publish(event)
    end
  end
end
