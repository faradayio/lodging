require 'emitter'

require 'lodging/impact_model'
require 'lodging/characterization'
require 'lodging/data'
require 'lodging/relationships'
require 'lodging/summarization'

module BrighterPlanet
  module Lodging
    extend BrighterPlanet::Emitter
    scope 'The lodging emission estimate is the anthropogenic emissions from lodging room energy use. It includes CO2 emissions from direct fuel combustion and indirect fuel combustion to generate purchased electricity.'
  end
end
