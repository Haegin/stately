require "active_support/concern"

module Stately
  module State
    extend ActiveSupport::Concern

    included do
      @events = []
    end

    class_methods do
      def transition(to: state, on: event, config: {})
        event_name = on.underscore.split("/").last.to_sym
        @events << event_name

        if config.has_key? :unless
          config[:if] = proc { |*args| !config[:unless].call(*args) }
        end

        define_method(event_name) do
          if config.fetch(:if) { proc { true } }.call(context)
            get_constant(on).new(source: self, destination: get_constant(to))
          end
        end

        define_method("can_#{event_name}?") do
          config.fetch(:if) { proc { true } }.call(context)
        end
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
