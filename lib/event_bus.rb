class EventBus
  def initialize
    @consumers = []
  end

  def add_consumer(consumer)
    @consumers << consumer
  end

  def publish(event)
    @consumers.each do |consumer|
      consumer.consume(event) if consumer.respond_to?(:consume)

      selector = :"consume_#{underscore(event.class.name)}"
      consumer.public_send(selector, event) if consumer.respond_to?(selector)
    end
  end

  private

  # Shamelessly copied and adapted from ActiveSupport
  # @see https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L90-L99
  def underscore(camel_cased_word)
    return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)
    word = camel_cased_word.to_s.gsub("::".freeze, "/".freeze)
    word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)(#{acronym_regex})(?=\b|[^a-z])/) { "#{$1 && '_'.freeze }#{$2.downcase}" }
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
    word.tr!("-".freeze, "_".freeze)
    word.downcase!
    word
  end

  def acronym_regex
    @acronym_regex ||=
      begin
        acronyms = %w(
        api
        http
        https
        rest
        ).map(&:downcase)
        /#{acronyms.join("|")}/
      end
  end
end
