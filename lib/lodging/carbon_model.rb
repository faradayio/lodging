# Copyright © 2010 Brighter Planet.
# See LICENSE for details.
# Contact Brighter Planet for dual-license arrangements.

## Lodging carbon model
# This model is used by [Brighter Planet](http://brighterplanet.com)'s carbon emission [web service](http://carbon.brighterplanet.com) to estimate the **greenhouse gas emissions of a lodging** (e.g. a hotel stay).
#
##### Calculations
# The final estimate is the result of the **calculations** detailed below. These calculations are performed in reverse order, starting with the last calculation listed and finishing with the `emission` calculation. Each calculation is named according to the value it returns.
#
##### Methods
# To accomodate varying client input, each calculation may have one or more **methods**. These are listed under each calculation in order from most to least preferred. Each method is named according to the values it requires. If any of these values is not available the method will be ignored. If all the methods for a calculation are ignored, the calculation will not return a value. "Default" methods do not require any values, and so a calculation with a default method will always return a value.
#
##### Standard compliance
# Each method lists any established calculation standards with which it **complies**. When compliance with a standard is requested, all methods that do not comply with that standard are ignored. This means that any values a particular method requires will have been calculated using a compliant method, because those are the only methods available. If any value did not have a compliant method in its calculation then it would be undefined, and the current method would have been ignored.
#
##### Collaboration
# Contributions to this carbon model are actively encouraged and warmly welcomed. This library includes a comprehensive test suite to ensure that your changes do not cause regressions. All changes should include test coverage for new functionality. Please see [sniff](http://github.com/brighterplanet/sniff#readme), our emitter testing framework, for more information.
module BrighterPlanet
  module Lodging
    module CarbonModel
      def self.included(base)
        base.decide :emission, :with => :characteristics do
          ### Emission calculation
          # Returns the `emission` estimate (*kg CO<sub>2</sub>e*).
          committee :emission do
            #### Emission from rooms, duration, and emission factor
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Multiplies `rooms` by `duration` and the `emission factor` (*kg CO<sub>2</sub>e / room-night*) to give (*kg CO<sub>2</sub>e).
            quorum 'from rooms, duration, and emission factor', :needs => [:rooms, :duration, :emission_factor], :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:rooms] * characteristics[:duration] * characteristics[:emission_factor]
            end
          end
          
          ### Emission factor calculation
          # Returns the `emission factor` (*kg CO<sub>2</sub>e / room-night*)
          committee :emission_factor do
            #### Emission factor from fuel intensities and eGRID
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # - Calculates an energy-based emission factor for [natural gas](http://data.brighterplanet.com/fuels) and [fuel oil](http://data.brighterplanet.com/fuels) by multiplying their `carbon content` (*g carbon / MJ*) by 1/1000 (*kg / g*) by 44/12 (*CO<sub>2</sub> / carbon*) to give *kg CO<sub>2</sub> / MJ*
            # - Calculates a volume-based emission factor for [natural gas](http://data.brighterplanet.com/fuels) and [fuel oil](http://data.brighterplanet.com/fuels) by multiplying their energy-based emission factor (*kg CO<sub>2</sub> / MJ*) by their `energy content` (*MJ / l or cubic m*) to give *kg CO<sub>2</sub> / litre or cubic m*
            # - Calculates an energy-based emission factor for district heat by dividing the energy-based natural gas emission factor by 0.817 and the energy-based fuel oil emission factor by 0.846 (to account for boiler inefficiencies), averaging the two, and dividing by 0.95 (to account for transmission losses) to give *kg CO<sub>2</sub> / MJ*
            # - Calculates an electricity emission factor by dividing the [eGRID subregion](http://data.brighterplanet.com/egrid_subregions) electricity emission factor by 1 - the [eGRID region](http://data.brighterplanet.com/egrid_regions) loss factor (to account for transmission and distribution losses) to give **kg CO<sub>2</sub> / kWh*
            # - Multiplies `natural gas intensity` by the volume-based natural gas emission factor, `fuel oil intensity` by the volume-based fuel oil emission factor, `electricity intensity` by the electricity emission factor, and `district heat intensity` by the energy-based district heat emission factor
            # - Adds these together
            quorum 'from fuel intensities and eGRID', :needs => [:natural_gas_intensity, :fuel_oil_intensity, :electricity_intensity, :district_heat_intensity, :egrid_subregion, :egrid_region], :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              natural_gas = Fuel.find_by_name "Pipeline Natural Gas"
              natural_gas_energy_ef = natural_gas.carbon_content.grams.to(:kilograms).carbon.to(:co2) # kg co2 / MJ
              natural_gas_ef = natural_gas_energy_ef * natural_gas.energy_content
              
              fuel_oil = Fuel.find_by_name "Distillate Fuel Oil No. 2"
              fuel_oil_energy_ef = fuel_oil.carbon_content.grams.to(:kilograms).carbon.to(:co2) # kg co2 / MJ
              fuel_oil_ef = fuel_oil_energy_ef * fuel_oil.energy_content
              
              district_heat_ef = (((natural_gas_energy_ef / 0.817) + (fuel_oil_energy_ef / 0.846)) / 2) / 0.95 # kg / MJ
              
              electricity_ef = characteristics[:egrid_subregion].electricity_emission_factor / (1 - characteristics[:egrid_region].loss_factor)
              
              (characteristics[:natural_gas_intensity] * natural_gas_ef) +
              (characteristics[:fuel_oil_intensity] * fuel_oil_ef) +
              (characteristics[:electricity_intensity] * electricity_ef) +
              (characteristics[:district_heat_intensity] * district_heat_ef)
            end
          end
          
          ### Natural gas intensity calculation
          # Returns the `natural gas intensity` (*cubic m / room-night*).
          committee :natural_gas_intensity do
            #### Natural gas intensity from census division
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [census division](http://data.brighterplanet.com/census_divisions) `natural gas intensity` (*cubic m / room-night*).
            quorum 'from census division', :needs => :census_division, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:census_division].lodging_building_natural_gas_intensity
            end
            
            #### Natural gas intensity from lodging class
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [lodging class](http://data.brighterplanet.com/lodging_class) `natural gas intensity` (*cubic m / room-night*).
            quorum 'from lodging class', :needs => :lodging_class, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:lodging_class].natural_gas_intensity
            end
          end
          
          ### Fuel oil intensity calculation
          # Returns the `fuel oil intensity` (*l / room-night*).
          committee :fuel_oil_intensity do
            #### Fuel oil intensity from census division
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [census division](http://data.brighterplanet.com/census_divisions) `fuel oil intensity` (*l / room-night*).
            quorum 'from census division', :needs => :census_division, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:census_division].lodging_building_fuel_oil_intensity
            end
            
            #### Fuel oil intensity from lodging class
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [lodging class](http://data.brighterplanet.com/lodging_class) `fuel oil intensity` (*l / room-night*).
            quorum 'from lodging class', :needs => :lodging_class, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:lodging_class].fuel_oil_intensity
            end
          end
          
          ### Electricity intensity calculation
          # Returns the `electricity intensity` (*kWh / room-night*).
          committee :electricity_intensity do
            #### Electricity intensity from census division
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [census division](http://data.brighterplanet.com/census_divisions) `electricity intensity` (*kWh / room-night*).
            quorum 'from census division', :needs => :census_division, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:census_division].lodging_building_electricity_intensity
            end
            
            #### Electricity intensity from lodging class
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [lodging class](http://data.brighterplanet.com/lodging classes) `electricity intensity` (*kWh / room-night*).
            quorum 'from lodging class', :needs => :lodging_class, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:lodging_class].electricity_intensity
            end
          end
          
          ### District heat intensity calculation
          # Returns the `district heat intensity` (*MJ / room-night*).
          committee :district_heat_intensity do
            #### District heat intensity from census division
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [census division](http://data.brighterplanet.com/census_divisions) `district heat intensity` (*MJ / room-night*).
            quorum 'from census division', :needs => :census_division, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:census_division].lodging_building_district_heat_intensity
            end
            
            #### District heat intensity from lodging class
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [lodging class](http://data.brighterplanet.com/lodging_classes) `district heat intensity` (*MJ / room-night*).
            quorum 'from lodging class', :needs => :lodging_class, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:lodging_class].district_heat_intensity
            end
          end
          
          ### Lodging class calculation
          # Returns the [lodging class](http://data.brighterplanet.com/lodging_classes).
          committee :lodging_class do
            #### Lodging class from client input
            # **Complies:** All
            #
            # Uses the client-input [loding class](http://data.brighterplanet.com/lodging_classes).
            
            #### Default lodging class
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Uses an artificial [lodging class](http://data.brighterplanet.com/lodging_classes) that represents the U.S. average.
            quorum 'default', :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
              LodgingClass.find_by_name 'Average'
            end
          end
          
          ### eGRID region calculation
          # Returns the lodging's [eGRID region](http://data.brighterplanet.com/egrid_regions).
          committee :egrid_region do
            #### eGRID region from eGRID subregion
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [eGRID subregion](http://data.brighterplanet.com/egrid_subregions) `eGRID region`.
            quorum 'from eGRID subregion', :needs => :egrid_subregion, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:egrid_subregion].egrid_region
            end
          end
          
          ### eGRID subregion calculation
          # Returns the lodging's [eGRID subregion](http://data.brighterplanet.com/egrid_subregions).
          committee :egrid_subregion do
            #### eGRID subregion from zip code
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [zip code](http://data.brighterplanet.com/zip_codes) `eGRID subregion`.
            quorum 'from zip code', :needs => :zip_code, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:zip_code].egrid_subregion
            end
            
            #### Default eGRID subregion
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Uses an artificial [eGRID subregion](http://data.brighterplanet.com/egrid_subregions) that represents the U.S. average.
            quorum 'default', :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
              EgridSubregion.find_by_abbreviation 'US'
            end
          end
          
          ### Census division calculation
          # Returns the lodging's [census division](http://data.brighterplanet.com/census_divisions).
          committee :census_division do
            #### Census division from state
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [state](http://data.brighterplanet.com/states) `census division`.
            quorum 'from state', :needs => :state, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:state].census_division
            end
          end
          
          ### State calculation
          # Returns the lodging's [state](http://data.brighterplanet.com/states).
          committee :state do
            #### State from zip code
            # **Complies:** GHG Protocol Scope 3, ISO 14064-1, Climate Registry Protocol
            #
            # Looks up the [zip code](http://data.brighterplanet.com/zip_codes) `state`.
            quorum 'from zip code', :needs => :zip_code, :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
              characteristics[:zip_code].state
            end
          end
          
          ### Zip code calculation
          # Returns the client-input [zip code](http://data.brighterplanet.com/zip_codes).
          
          ### Duration calculation
          # Returns the stay's `duration` (*nights*).
          committee :duration do
            #### Duration from client input
            # **Complies:** All
            #
            # Uses the client-input `duration` (*nights*).
            
            #### Default duration
            # **Complies:**
            #
            # Uses 1 *night*.
            quorum 'default' do
              1
            end
          end
          
          ### Rooms calculation
          # Returns the number of `rooms` used.
          committee :rooms do
            #### Rooms from client input
            # **Complies:** All
            #
            # Uses the client-input number of `rooms`.
            
            #### Default rooms
            # **Complies:**
            #
            # Uses 1 room.
            quorum 'default' do
              1
            end
          end
        end
      end
    end
  end
end
