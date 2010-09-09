require 'leap'
require 'conversions'

module BrighterPlanet
  module Lodging
    module CarbonModel
      def self.included(base)
        base.extend ::Leap::Subject
        base.decide :emission, :with => :characteristics do
          committee :emission do # returns kg CO2
            quorum 'default' do
              1
            end
          end
        end
      end
    end
  end
end
