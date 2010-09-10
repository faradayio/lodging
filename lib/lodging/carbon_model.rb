require 'leap'
require 'conversions'

module BrighterPlanet
  module Lodging
    module CarbonModel
      def self.included(base)
        base.extend ::Leap::Subject
        base.decide :emission, :with => :characteristics do
          committee :emission do # returns kg CO2e
            quorum 'from magnitude and emission factor', :needs => [:magnitude, :emission_factor] do |characteristics|
              characteristics[:magnitude] * characteristics[:emission_factor]
            end
            
            quorum 'default' do
              raise "The emission committee's default quorum should never be called."
            end
          end
          
          committee :emission_factor do # returns kg CO2e per room night
            quorum 'default' do
              LodgingClass.fallback.emission_factor
            end
          end
          
          committee :magnitude do # return room-nights - couldn't think of anything to call it except 'magnitude'
            quorum 'default' do
              base.fallback.magnitude
            end
          end
        end
      end
    end
  end
end
