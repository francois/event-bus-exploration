class PGEventStoreConsumer
  def initialize(repository)
    @repository = repository
  end

  def consume(event, replay: false)
    @repository.create_event(event) unless replay
  end
end
