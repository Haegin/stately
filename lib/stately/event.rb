module Stately
  module Event
    attr_reader :source, :destination

    def initialize(source:, destination:)
      @source = source
      @destination = destination
    end

    def process
      destination.new(source.context)
    end
  end
end
