require 'emitter'

module BrighterPlanet
  module Lodging
    extend BrighterPlanet::Emitter
    scope 'The lodging emission estimate is the anthropogenic emissions from lodging room energy use. It includes CO2 emissions from direct fuel combustion and fuel combustion to generate electricity.'
  end
end
