require "active_support/concern"

module Stately
  module Machine
    extend ActiveSupport::Concern

    class_methods do
      def initial_state=(state)
        @initial_state = state
      end

      def initial_state
        @initial_state
      end
    end

    attr_reader :state

    def initialize
      initial_state = self.class.initial_state.constantize
      @state = initial_state.new(self)
    end

    def respond_to?(method)
      state.accepts_event?(method) ||
        state.respond_to?(method) ||
        super
    end

    def method_missing(method, *args, &block)
      if state.accepts_event?(method)
        fire_event(method)
      elsif state.respond_to?(method)
        state.public_send(method, *args, &block)
      else
        super
      end
    end

    private

    def fire_event(method)
      # Call the method we created on the state for this event, passing
      # ourself in as the context
      event = state.public_send(method)
      if event
        @state = event.process
      else
        false
      end
    end
  end
end

