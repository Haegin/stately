module Stately
  class StateMachine
    attr_reader :state

    def initialize(state)
      @state = state
    end

    def respond_to?(method)
      state.accepts_event?(method) || super
    end

    def method_missing(method, *args, &block)
      if state.accepts_event?(method)
        event = state.public_send(method)
        @state = event.process
      else
        super
      end
    end
  end
end
