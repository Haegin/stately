module Stately
  class StateMachine
    attr_reader :state

    def initialize(state)
      @state = state
    end

    def respond_to?(method)
      state.accepts_event?(method) ||
        state.respond_to?(method) ||
        super
    end

    def method_missing(method, *args, &block)
      if state.accepts_event?(method)
        event = state.public_send(method)
        @state = event.process
      elsif state.respond_to?(method)
        state.public_send(method, *args, &block)
      else
        super
      end
    end
  end
end
