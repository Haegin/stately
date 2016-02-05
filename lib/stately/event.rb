module Stately
  module Event
    attr_reader :destination

    def initialize(destination:)
      @destination = destination
    end

    def process
      destination.new
    end
  end
end
