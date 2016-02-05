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

    attr_reader :state_machine
    delegate :state, to: :state_machine

    def initialize
      initial_state = self.class.initial_state.constantize
      @state_machine = StateMachine.new(initial_state.new)
    end

    def respond_to?(method)
      state_machine.respond_to?(method) || super
    end

    def method_missing(method, *args, &block)
      state_machine.public_send(method, *args, &block) || super
    end
  end
end
