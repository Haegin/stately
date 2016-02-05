require "active_support/concern"

module Stately
  module State
    extend ActiveSupport::Concern

    included do
      @events = []
    end

    class_methods do
      def transition(to: state, on: event, **config)
        transition = Transition.new(source: self, destination: to, event: on, config: config)
        @events << transition.event_name
        define_method(transition.event_name, proc { transition.action { self }.call })
        define_method("can_#{transition.event_name}?", proc do
          transition.guard.call(proc { self }.call.context)
        end)
      end

      def events
        @events
      end
    end

    attr_reader :context

    def initialize(context)
      @context = context
    end

    def accepts_event?(event)
      self.class.events.include?(event)
    end

    private

    def get_constant(str)
      str.constantize
    rescue NameError
      [self.class.name.deconstantize, str].join("::").constantize
    end
  end
end
