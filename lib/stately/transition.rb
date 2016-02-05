module Stately
  class Transition
    attr_reader :source, :destination, :event, :config

    def initialize(source:, destination:, event:, config: {})
      @source = source
      @destination = destination
      @event = event
      @config = config
    end

    def event_name
      @event_name ||= event.underscore.split("/").last.to_sym
    end

    def guard
      if config.key?(:if)
        config[:if]
      elsif config.key?(:unless)
        unless_proc = config[:unless]
        proc { |*args| !unless_proc.call(*args) }
      else
        proc { true }
      end
    end

    def action(&block)
      proc do
        source = block_given? ? block.call : Stately::NullState.new
        if guard.call(source.context)
          event_class.new(source: source, destination: destination_class)
        end
      end
    end

    def event_class
      get_constant(event)
    end

    def destination_class
      get_constant(destination)
    end

    private

    def get_constant(str)
      str.constantize
    rescue NameError
      [source.name.deconstantize, str].join("::").constantize
    end
  end
end
