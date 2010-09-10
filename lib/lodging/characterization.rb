require 'characterizable'

module BrighterPlanet
  module Lodging
    module Characterization
      def self.included(base)
        base.send :include, Characterizable
        base.characterize do
          has :magnitude  # room-nights
        end
        base.add_implicit_characteristics
      end
    end
  end
end
