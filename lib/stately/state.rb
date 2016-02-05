require "active_support/concern"

module Stately
  module State
    extend ActiveSupport::Concern

    included do
      @events = []
    end

    class_methods do
      def transition_to(state, on: event)
        @events << on.underscore.to_sym
        define_method(on.underscore) do
          get_constant(on).new(destination: get_constant(state))
        end
      end

      def events
        @events
      end
    end

    def accepts_event?(event)
      self.class.events.include?(event)
    end

    private

    def get_constant(str)
      [self.class.name.deconstantize, str].join("::").constantize
    end
  end
end
