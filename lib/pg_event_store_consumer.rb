class PGEventStoreConsumer
  def initialize(repository)
    @repository = repository
  end

  def consume(event)
    @repository.create_event(event)
  end
end
