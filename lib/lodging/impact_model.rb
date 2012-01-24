# Copyright © 2010 Brighter Planet.
# See LICENSE for details.
# Contact Brighter Planet for dual-license arrangements.

## Lodging impact model
# This model is used by the [Brighter Planet](http://brighterplanet.com) [CM1 web service](http://carbon.brighterplanet.com) to calculate the impacts of a lodging (e.g. a hotel stay), such as energy use, greenhouse gas emissions, and water use.

##### Timeframe
# The model calculates impacts that occured during a particular time period (`timeframe`).
# For example if the `timeframe` is February 2010, a lodging that occurred (`date`) on February 15, 2010 will have impacts, but a lodging that occurred on January 31, 2010 will have zero impacts.
#
# The default `timeframe` is the current calendar year.

##### Calculations
# The final impacts are the result of the calculations below. These are performed in reverse order, starting with the last calculation listed and finishing with the greenhouse gas emissions calculation.
#
# Each calculation listing shows:
#
# * value returned (*units of measurement*)
# * description of the value
# * calculation methods, listed from most to least preferred
#
# Some methods use `values` returned by prior calculations. If any of these `values` are unknown the method is skipped.
# If all the methods for a calculation are skipped, the value the calculation would return is unknown.

##### Standard compliance
# When compliance with a particular standard is requested, all methods that do not comply with that standard are ignored.
# Thus any `values` a method needs will have been calculated using a compliant method or will be unknown.
# To see which standards a method complies with, look at the `:complies =>` section of the code in the right column.
#
# Client input complies with all standards.

##### Collaboration
# Contributions to this impact model are actively encouraged and warmly welcomed. This library includes a comprehensive test suite to ensure that your changes do not cause regressions. All changes should include test coverage for new functionality. Please see [sniff](https://github.com/brighterplanet/sniff#readme), our emitter testing framework, for more information.
module BrighterPlanet
  module Lodging
    module ImpactModel
      def self.included(base)
        base.decide :impact, :with => :characteristics do
          # * * *
          
          #### Carbon (*kg CO<sub>2</sub>e*)
          # *The lodging's total anthropogenic greenhouse gas emissions during `timeframe`.*
          committee :carbon do
            # Multiply `natural gas use` (*m<sup>3</sup>*) by its emission factor (*kg CO<sub>2</sub> / m<sup>3</sup>*),
            # multiply `fuel oil use` (*l*) by its emission factor (*kg CO<sub>2</sub> / l*),
            # multiply `electricity use` (*kWh*) by `electricity emission factor` (*kg CO<sub>2</sub>e / kWh*),
            # and sum to give *kg CO<sub>2</sub>e.
            quorum 'from natural gas use, fuel oil use, electricity use, and electricity emission factor', :needs => [:natural_gas_use, :fuel_oil_use, :electricity_use, :electricity_emission_factor],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:natural_gas_use] * Fuel.find_by_name('Pipeline Natural Gas').co2_emission_factor +
                characteristics[:fuel_oil_use] * Fuel.find_by_name('Distillate Fuel Oil No. 2').co2_emission_factor +
                characteristics[:electricity_use] * characteristics[:electricity_emission_factor]
            end
          end
          
          #### Electricity emission factor (*kg CO<sub>2</sub>e / kWh*)
          # *A greenhouse gas emission factor for electricity used by the lodging.*
          committee :electricity_emission_factor do
            # Multiply the `eGRID subregion` electricity emission factors by 1 minus the the subregion's eGRID region loss factor (to account for transmission and distribution losses) to give *kg CO<sub>2</sub>e / kWh*.
            quorum 'from eGRID subregion', :needs => :egrid_subregion,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:egrid_subregion].electricity_emission_factor / (1 - characteristics[:egrid_subregion].egrid_region.loss_factor)
            end
            
            # Otherwise look up the `country` electricity emission factor (*kg CO<sub>2</sub>e / kWh*).
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country].electricity_emission_factor
            end
            
            # Otherwise use a global average electricity emission factor (*kg CO<sub>2</sub>e / kWh*).
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                Country.fallback.electricity_emission_factor
            end
          end
          
          #### Natural gas use (*m<sup>3</sup>*)
          # The lodging's natural gas use during `timeframe`.
          committee :natural_gas_use do
            # 
            quorum 'from fuels use equation and inputs', :needs => :fuels_use_equation, :appreciates => [:property_rooms, :property_construction_year],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                fuels_use = if characteristics[:property_rooms].present? and characteristics[:property_construction_year].present?
                  characteristics[:fuels_use_equation].constant + (characteristics[:fuels_use_equation].rooms_factor * characteristics[:property_rooms].value) + (characteristics[:fuels_use_equation].year_factor * characteristics[:property_construction_year].value)
                elsif characteristics[:property_rooms].present?
                  characteristics[:fuels_use_equation].constant + (characteristics[:fuels_use_equation].rooms_factor * characteristics[:property_rooms].value)
                elsif characteristics[:property_construction_year].present?
                  characteristics[:fuels_use_equation].constant + (characteristics[:fuels_use_equation].year_factor * characteristics[:property_construction_year].value)
                else
                  characteristics[:fuels_use_equation].constant
                end
                gas_energy = fuels_use * characteristics[:fuels_use_equation].gas_share
                
                gas_to_make_steam_energy = (fuels_use * characteristics[:fuels_use_equation].steam_share / 2.0 / 0.817 / 0.95)
                
                (gas_energy + gas_to_make_steam_energy) / 0.59 / Fuel.find('Pipeline Natural Gas').energy_content
            end
            
            quorum 'from fuel intensities and room nights', :needs => [:fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                # Otherwise multiply `room nights` (*room-nights*) by `natural gas intensity` (*m<sup>3</sup> / room-night*) to give direct natural gas use (*m<sup>3</sup>*).
                direct_gas_use = characteristics[:room_nights] * characteristics[:fuel_intensities][:natural_gas]
                
                # Multiply `room nights` (*room-nights*) by `steam intensity` (*MJ / room-night*) to give steam use (*MJ*). Assume half of this was generated by natural gas boilers with 81.7% efficiency and that transmission losses are 5%; divide by natural gas energy content (*MJ / m<sup>3</sup>*) to give indirect natural gas use (*m<sup>3</sup>*).
                indirect_gas_use = (characteristics[:room_nights] * characteristics[:fuel_intensities][:steam] / 2.0 / 0.817 / 0.95) / Fuel.find('Pipeline Natural Gas').energy_content
                
                # Sum direct and indirect natural gas use to give *m<sup>3</sup>*.
                direct_gas_use + indirect_gas_use
            end
          end
          
          #### Fuel oil use (*l*)
          # The lodging's fuel oil use during `timeframe`.
          committee :fuel_oil_use do
            quorum 'from fuels use equation and inputs', :needs => :fuels_use_equation, :appreciates => [:property_rooms, :property_construction_year],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                fuels_use = if characteristics[:property_rooms].present? and characteristics[:property_construction_year].present?
                  characteristics[:fuels_use_equation].constant + (characteristics[:fuels_use_equation].rooms_factor * characteristics[:property_rooms].value) + (characteristics[:fuels_use_equation].year_factor * characteristics[:property_construction_year].value)
                elsif characteristics[:property_rooms].present?
                  characteristics[:fuels_use_equation].constant + (characteristics[:fuels_use_equation].rooms_factor * characteristics[:property_rooms].value)
                elsif characteristics[:property_construction_year].present?
                  characteristics[:fuels_use_equation].constant + (characteristics[:fuels_use_equation].year_factor * characteristics[:property_construction_year].value)
                else
                  characteristics[:fuels_use_equation].constant
                end
                oil_energy = fuels_use * characteristics[:fuels_use_equation].oil_share
                
                oil_to_make_steam_energy = (fuels_use * characteristics[:fuels_use_equation].steam_share / 2.0 / 0.846 / 0.95)
                
                (oil_energy + oil_to_make_steam_energy) / 0.59 / Fuel.find('Distillate Fuel Oil No. 2').energy_content
            end
            
            quorum 'from fuel intensities and room nights', :needs => [:fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                # Otherwise multiply `room nights` (*room-nights*) by `fuel oil intensity` (*l / room-night*) to give direct fuel oil use (*l*).
                direct_oil_use = characteristics[:room_nights] * characteristics[:fuel_intensities][:fuel_oil]
                
                # Multiply `room nights` (*room-nights*) by `steam intensity` (*MJ / room-night*) to give steam use (*MJ*). Assume half of this was generated by fuel oil boilers with 84.6% efficiency and that transmission losses are 5%; divide by fuel oil energy content (*MJ / l*) to give indirect fuel oil use (*l*).
                indirect_oil_use = (characteristics[:room_nights] * characteristics[:fuel_intensities][:steam] / 2.0 / 0.846 / 0.95) / Fuel.find('Distillate Fuel Oil No. 2').energy_content
                
                # Sum direct and indirect fuel oil use to give *l*.
                direct_oil_use + indirect_oil_use
            end
          end
          
          #### Electricity use (*kWh*)
          # The lodging's electricity use during `timeframe`.
          committee :electricity_use do
            quorum 'from electricity use equation and inputs', :needs => :electricity_use_equation, :appreciates => [:property_rooms, :property_construction_year],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                electricity_energy = if characteristics[:property_rooms].present? and characteristics[:property_construction_year].present?
                  characteristics[:electricity_use_equation].constant * (characteristics[:electricity_use_equation].rooms_factor ** characteristics[:property_rooms].value) * (characteristics[:electricity_use_equation].year_factor ** characteristics[:property_construction_year].value)
                elsif characteristics[:property_rooms].present?
                  characteristics[:electricity_use_equation].constant * (characteristics[:electricity_use_equation].rooms_factor ** characteristics[:property_rooms].value)
                elsif characteristics[:property_construction_year].present?
                  characteristics[:electricity_use_equation].constant * (characteristics[:electricity_use_equation].year_factor ** characteristics[:property_construction_year].value)
                else
                  characteristics[:electricity_use_equation].constant
                end
                (electricity_energy / 0.59).megajoules.to(:kilowatt_hours)
            end
            
            # Multiply `room nights` (*room-nights*) by `electricity intensity` (*kWh / room-night*) to give *kWh*.
            quorum 'from fuel intensities and room nights', :needs => [:fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:fuel_intensities][:electricity]
            end
          end
          
          #### Fuels use equation
          committee :fuels_use_equation do
            quorum 'from available characteristics', :appreciates => [:climate_zone_number, :property_rooms, :property_construction_year],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                # criteria = characteristics.keys.inject({}) do |memo, key|
                #   memo[key] = characteristics[key].value
                #   memo
                # end
                LodgingFuelUseEquation.find_by_criteria('Fuels', characteristics)
            end
          end
          
          #### Electricity use equation
          committee :electricity_use_equation do
            quorum 'from available characteristics', :appreciates => [:climate_zone_number, :property_rooms, :property_construction_year],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
=begin
                Need to strip all Charisma crap from characteristics before passing to LodgingFuelUseEquation
=end
                # criteria = characteristics.keys.inject({}) do |memo, key|
                #   memo[key] = characteristics[key].value
                #   memo
                # end
                LodgingFuelUseEquation.find_by_criteria('Electricity', characteristics)
            end
          end
          
          #### Fuel intensities (*various*)
          # *The lodging's use per occupied room night of a variety of fuels.*
          committee :fuel_intensities do
            # For each record in the cohort, multiply months used (*months*) by 365 (*days / year*) and divide by 7 (*days / week*) and by 12 (*months / year*) to give *weeks* the surveyed building was used.
            # Divide weekly hours (*hours / week*) by 24 (*hours / day*) and multiply by *weeks* to give *days* the survey building was used.
            # Multiply by the number of rooms in the lodging property and 0.59 (average occupancy after PriceWaterhouseCoopers) to give *occupied room nights*.
            # Divide total use of each fuel by *occupied room nights* to give *fuel / room-night*.
            # Calculate the weighted average of each intensity across all records in the `cohort` to give:
            #
            # - Natural gas intensity: *m<sup>3</sup> / room-night*
            # - Fuel oil intensity: *l / room-night*
            # - Electricity intensity: *kWh / room-night*
            # - Steam heat intensity: *MJ / room-night*
            quorum 'from cohort', :needs => :cohort,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                intensities = {}
                [:natural_gas, :fuel_oil, :electricity, :steam].each do |fuel|
                  intensities[fuel] = characteristics[:cohort].inject(0) do |sum, record|
                    next sum unless record.send("#{fuel}_use").present?
=begin
  days/year * weeks/day * years/month = weeks/month
  weeks/month * months in a year = weeks in a year
  weeks in a year * hours/week = hours in a year
  hours in a year * days/hour = days in a year
=end
                    occupied_room_nights = 365.0 / 7.0 / 12.0 * record.months_used * record.weekly_hours / 24.0 * record.lodging_rooms * 0.59
                    sum + (record.weighting * record.send("#{fuel}_use") / occupied_room_nights)
                  end / characteristics[:cohort].sum(:weighting)
                end
                intensities
            end
            
            # Otherwise look up the `country lodging class` fuel intensities:
            #
            # - Natural gas intensity: *m<sup>3</sup> / room-night*
            # - Fuel oil intensity: *l / room-night*
            # - Electricity intensity: *kWh / room-night*
            # - Steam heat intensity: *MJ / room-night*
            quorum 'from country lodging class', :needs => :country_lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                {
                  :natural_gas   => characteristics[:country_lodging_class].natural_gas_intensity,
                  :fuel_oil      => characteristics[:country_lodging_class].fuel_oil_intensity,
                  :electricity   => characteristics[:country_lodging_class].electricity_intensity,
                  :steam         => characteristics[:country_lodging_class].steam_intensity,
                }
            end
            
            # Otherwise look up the `country` lodging fuel intensities:
            #
            # - Natural gas intensity: *m<sup>3</sup> / room-night*
            # - Fuel oil intensity: *l / room-night*
            # - Electricity intensity: *kWh / room-night*
            # - Steam intensity: *MJ / room-night*
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                intensities = {
                  :natural_gas   => characteristics[:country].lodging_natural_gas_intensity,
                  :fuel_oil      => characteristics[:country].lodging_fuel_oil_intensity,
                  :electricity   => characteristics[:country].lodging_electricity_intensity,
                  :steam         => characteristics[:country].lodging_steam_intensity,
                }
                # Ignore the `country` fuel intensities if they're all blank.
                intensities.values.compact.empty? ? nil : intensities
            end
            
            # Otherwise look up global average lodging fuel intensities:
            #
            # - Natural gas intensity: *m<sup>3</sup> / room-night*
            # - Fuel oil intensity: *l / room-night*
            # - Electricity intensity: *kWh / room-night*
            # - Steam intensity: *MJ / room-night*
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                {
                  :natural_gas   => Country.fallback.lodging_natural_gas_intensity,
                  :fuel_oil      => Country.fallback.lodging_fuel_oil_intensity,
                  :electricity   => Country.fallback.lodging_electricity_intensity,
                  :steam         => Country.fallback.lodging_steam_intensity,
                }
            end
          end
          
          #### Cohort
          # *A set of responses from the [EIA Commercial Buildings Energy Consumption Survey](http://data.brighterplanet.com/commercial_building_energy_consumption_survey_responses) that represent buildings similar to the lodging property.*
          committee :cohort do
            # If the lodging is in the United States and we know `census division`, assemble a cohort of CBECS responses:
            # Start with all responses, and then select only the responses that match `census region`, `country lodging class`, and `census division`.
            # If fewer than 8 responses match all of those characteristics, drop the last characteristic (initially `census division`) and try again.
            # Continue until we have 8 or more responses or we've dropped all the characteristics.
            quorum 'from census division and input', :needs => :census_division, :appreciates => :country_lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                provided_characteristics = [[:census_region_number, characteristics[:census_division].census_region_number]]
                provided_characteristics << [:detailed_activity, characteristics[:country_lodging_class].cbecs_detailed_activity] if characteristics[:country_lodging_class].present?
                provided_characteristics << [:census_division_number, characteristics[:census_division].number]
                
                cohort = CommercialBuildingEnergyConsumptionSurveyResponse.lodging_records.strict_cohort(*provided_characteristics)
                cohort.any? ? cohort : nil
            end
          end
          
          #### Property construction year
          # *The year the lodging property was built.*
          committee :property_construction_year do
            # Use client input, if available.
            
            # Otherwise look up the `lodging property` construction year.
            quorum 'from lodging property', :needs => :lodging_property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:lodging_property].construction_year
            end
          end
          
          #### Property rooms
          # *The number of guest rooms in the lodging property.*
          committee :property_rooms do
            # Use client input, if available.
            
            # Otherwise look up the `lodging property` number of rooms.
            quorum 'from lodging property', :needs => :lodging_property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:lodging_property].lodging_rooms
            end
          end
          
          #### Country lodging class
          # *The lodging's [country-specific lodging class](http://data.brighterplanet.com/country_lodging_classes).*
          committee :country_lodging_class do
            # Check whether the combination of `country` and `lodging class` matches a record in our database.
            quorum 'from country and lodging class', :needs => [:country, :lodging_class],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                CountryLodgingClass.find_by_country_iso_3166_code_and_lodging_class_name(characteristics[:country].iso_3166_code, characteristics[:lodging_class].name)
            end
          end
          
          #### Lodging class
          # *The [lodging's class](http://data.brighterplanet.com/lodging_classes).*
          committee :lodging_class do
            # Use client input, if available.
            
            # Otherwise look up the `lodging property` lodging class.
            quorum 'from lodging property', :needs => :lodging_property,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:lodging_property].lodging_class
            end
          end
          
          #### Lodging property
          # *The property where the stay occurred.*
          committee :lodging_property do
            # Use a custom matching algorithm to look up a lodging property based on user inputs.
            quorum "from custom matching algorithm", :needs => :lodging_property_name, :appreciates => [:zip_code, :city, :state],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                LodgingProperty.better_match characteristics if LodgingProperty.respond_to?(:better_match)
            end
=begin
            CAREFUL! there isn't a test for the custom algorithm quorum
=end
            
            # Otherwise check whether `lodging property name` matches a property in `zip code`.
            quorum "from lodging property name and zip code", :needs => [:lodging_property_name, :zip_code],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                LodgingProperty.where(:postcode => characteristics[:zip_code].name).find_by_name characteristics[:lodging_property_name].value
            end
            
            # Otherwise check whether `lodging property name` matches a property in `city`, `state`.
            quorum "from lodging property name, city, and state", :needs => [:lodging_property_name, :city, :state],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                LodgingProperty.where(:city => characteristics[:city].value, :locality => characteristics[:state].name).find_by_name characteristics[:lodging_property_name].value
            end
          end
          
          #### Lodging property name
          # *The name of the property where the stay occurred.*
          #
          # Use client input, if available
          
          #### Climate zone number
          # *The lodging property's [climate zone number](http://www.eia.gov/emeu/cbecs/climate_zones.html).*
          committee :climate_zone_number do
            # Look up the `climate division` climate zone number.
            quorum 'from climate division', :needs => :climate_division,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:climate_division].climate_zone_number
            end
            
            # Look up the `state` climate zone number.
            quorum 'from state', :needs => :state,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:state].climate_zone_number
            end
          end
          
          #### Climate division
          # *The lodging property's [climate division](http://data.brighterplanet.com/climate_divisions).*
          committee :climate_division do
            # Look up the `zip code` climate division.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].climate_division
            end
          end
          
          #### Census division
          # *The lodging property's [census division](http://data.brighterplanet.com/census_divisions).*
          committee :census_division do
            # Look up the `state` census division.
            quorum 'from state', :needs => :state,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:state].census_division
            end
          end
          
          #### eGRID subregion
          # *The lodging property's [eGRID subregion](http://data.brighterplanet.com/egrid_subregions).*
          committee :egrid_subregion do
            # Look up the `zip code` eGRID subregion.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].egrid_subregion
            end
          end
          
          #### Country
          # *The lodging property's [country](http://data.brighterplanet.com/countries).*
          committee :country do
            # Use client input, if available.
            
            # If state is defined then the country is the United States.
            quorum 'from state', :needs => :state,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                Country.united_states
            end
          end
          
          #### State
          # *The lodging property's [US state](http://data.brighterplanet.com/states).*
          committee :state do
            # Use client input, if available.
            
            # Otherwise look up the `zip code` state.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].state
            end
          end
          
          #### City
          # *The lodging property's city.*
          committee :city do
            # Use client input, if available.
            
            # Otherwise look up the `zip code` description.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].description
            end
          end
          
          #### Zip code
          # *The lodging property's [US zip code](http://data.brighterplanet.com/zip_codes).*
          #
          # Use client input, if available.
          
          #### Room nights (*room-nights*)
          # The stay's room-nights that occurred during `timeframe`.
          committee :room_nights do
            # If `date` falls within `timeframe`, divide `duration` (*seconds*) by 86,400 (*seconds / night*) and multiply by `rooms` to give *room-nights*.
            # Otherwise `room nights` is zero.
            quorum 'from rooms, duration, date, and timeframe', :needs => [:rooms, :duration, :date],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics, timeframe|
                date = characteristics[:date].is_a?(Date) ? characteristics[:date] : Date.parse(characteristics[:date].to_s)
                timeframe.include?(date) ? characteristics[:duration] / 86400.0 * characteristics[:rooms] : 0
            end
          end
          
          #### Duration (*seconds*)
          # *The stay's duration.*
          committee :duration do
            # Use client input, if available.
            
            # Otherwise use 86400 *seconds* (1 night).
            quorum 'default' do
              86400.0
            end
          end
          
          #### Rooms
          # *The number of rooms used.*
          committee :rooms do
            # Use client input, if available.
            
            # Otherwise use 1 *room*.
            quorum 'default' do
              1
            end
          end
          
          #### Date (*date*)
          # *The day the stay occurred.*
          committee :date do
            # Use client input, if available.
            
            # Otherwise use the first day of `timeframe`.
            quorum 'from timeframe',
              :complies => [:ghg_protocol_scope_3, :iso] do |characteristics, timeframe|
                timeframe.from
            end
          end
        end
      end
    end
  end
end
