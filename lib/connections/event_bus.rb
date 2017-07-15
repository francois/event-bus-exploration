require "connections/database"
require "event_bus"
require "pg_event_store_consumer"
require "transactional_event_bus"
require "user_registration_consumer"

EVENT_BUS = TransactionalEventBus.new(event_bus: EventBus.new, db: DB)
EVENT_BUS.add_consumer(PGEventStoreConsumer.new(REPOSITORY))
EVENT_BUS.add_consumer(UserRegistrationConsumer.new(REPOSITORY))
