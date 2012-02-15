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
            # Multiply by `emission factor` (*kg CO<sub>2</sub>e / room-night*) to give *kg CO<sub>2</sub>e.
            quorum 'from natural gas use, fuel oil use, electricity use, district heat use, electricity emission factor, and district heat emission factor', :needs => [:natural_gas_use, :fuel_oil_use, :electricity_use, :district_heat_use, :electricity_emission_factor, :district_heat_emission_factor],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:natural_gas_use] * Fuel.find_by_name('Pipeline Natural Gas').co2_emission_factor +
                characteristics[:fuel_oil_use] * Fuel.find_by_name('Distillate Fuel Oil No. 2').co2_emission_factor +
                characteristics[:electricity_use] * characteristics[:electricity_emission_factor] +
                characteristics[:district_heat_use] * characteristics[:district_heat_emission_factor]
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
          
          #### District heat emission factor (*kg CO<sub>2</sub> / MJ*)
          # *A greenhouse gas emission factor for district heat used by the lodging.*
          committee :district_heat_emission_factor do
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                # Calculate an energy-based emission factor for [natural gas](http://data.brighterplanet.com/fuels) by dividing its CO<sub>2</sub> emission factor (*kg / m<sup>3</sup>*) by its energy content (*MJ / m<sup>3</sup>*) to give *kg CO<sub>2</sub> / MJ*.
                natural_gas = Fuel.find_by_name 'Pipeline Natural Gas'
                natural_gas_energy_ef = natural_gas.co2_emission_factor / natural_gas.energy_content
                
                # Calculate an energy-based emission factor for [fuel oil](http://data.brighterplanet.com/fuels) by dividing its CO<sub>2</sub> emission factor (*kg / l*) by its energy content (*MJ / l*) to give *kg CO<sub>2</sub> / MJ*.
                fuel_oil = Fuel.find_by_name 'Distillate Fuel Oil No. 2'
                fuel_oil_energy_ef = fuel_oil.co2_emission_factor / fuel_oil.energy_content
                
                # Assume half of district heat is generated by natural gas boilers with 81.7% efficiency, half is generated by fuel oil boilers with 84.6% efficiency, and that transmission losses are 5%, giving *kg CO<sub>2</sub> / MJ*.
                (((natural_gas_energy_ef / 0.817) + (fuel_oil_energy_ef / 0.846)) / 2.0) / 0.95
            end
          end
          
          #### Natural gas use (*m<sup>3</sup>*)
          # The lodging's natural gas use during `timeframe`.
          committee :natural_gas_use do
            # Multiply `room nights` (*room-nights*) by `natural gas intensity` (*m<sup>3</sup> / room-night*) to give *m<sup>3</sup>*.
            quorum 'from fuel intensities and room nights', :needs => [:fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:fuel_intensities][:natural_gas]
            end
          end
          
          #### Fuel oil use (*l*)
          # The lodging's fuel oil use during `timeframe`.
          committee :fuel_oil_use do
            # Multiply `room nights` (*room-nights*) by `fuel oil intensity` (*l / room-night*) to give *l*.
            quorum 'from fuel intensities and room nights', :needs => [:fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:fuel_intensities][:fuel_oil]
            end
          end
          
          #### Electricity use (*kWh*)
          # The lodging's electricity use during `timeframe`.
          committee :electricity_use do
            # Multiply `room nights` (*room-nights*) by `electricity intensity` (*kWh / room-night*) to give *kWh*.
            quorum 'from fuel intensities and room nights', :needs => [:fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:fuel_intensities][:electricity]
            end
          end
          
          #### District heat use (*MJ*)
          # The lodging's district heat use during `timeframe`.
          committee :district_heat_use do
            # Multiply `room nights` (*room-nights*) by `district heat intensity` (*MJ / room-night*) to give *MJ*.
            quorum 'from fuel intensities and room nights', :needs => [:fuel_intensities, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:fuel_intensities][:district_heat]
            end
          end
          
          #### Fuel intensities (*various*)
          # *The lodging's use per occupied room night of a variety of fuels.*
          committee :fuel_intensities do
            # For each record in the cohort, multiply months used (*months*) by 365 (*days / year*) and divide by 7 (*days / week*) and by 12 (*months / year*) to give *weeks* the surveyed building was used.
            # Divide weekly hours (*hours / week*) by 24 (*hours / day*) and multiply by *weeks* to give *days* the survey building was used.
            # Multiply by the number of rooms in the lodging property and 0.601 (average occupancy after http://www.pwc.com/us/en/press-releases/2012/pwc-us-lodging-industry-forecast.jhtml) to give *occupied room nights*.
            # Divide total use of each fuel by *occupied room nights* to give *fuel / room-night*.
            # Calculate the weighted average of each intensity across all records in the `cohort` to give:
            #
            # - Natural gas intensity: *m<sup>3</sup> / room-night*
            # - Fuel oil intensity: *l / room-night*
            # - Electricity intensity: *kWh / room-night*
            # - District heat intensity: *MJ / room-night*
            quorum 'from cohort', :needs => :cohort,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                occupancy_rate = Country.united_states.lodging_occupancy_rate
                total_cohort_weight = characteristics[:cohort].sum(:weighting)
                intensities = {}
                [:natural_gas, :fuel_oil, :electricity, :district_heat].each do |fuel|
                  intensities[fuel] = characteristics[:cohort].inject(0) do |sum, record|
                    next sum unless record.send("#{fuel}_use").present?
=begin
  days/year * weeks/day * years/month = weeks/month
  weeks/month * months in a year = weeks in a year
  weeks in a year * hours/week = hours in a year
  hours in a year * days/hour = days in a year
=end
                    occupied_room_nights = 365.0 / 7.0 / 12.0 * record.months_used * record.weekly_hours / 24.0 * record.lodging_rooms * occupancy_rate
                    sum + (record.weighting * record.send("#{fuel}_use") / occupied_room_nights)
                  end / total_cohort_weight
                end
                intensities
            end
            
            # Otherwise look up the `country lodging class` fuel intensities:
            #
            # - Natural gas intensity: *m<sup>3</sup> / room-night*
            # - Fuel oil intensity: *l / room-night*
            # - Electricity intensity: *kWh / room-night*
            # - District heat intensity: *MJ / room-night*
            quorum 'from country lodging class', :needs => :country_lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                {
                  :natural_gas   => characteristics[:country_lodging_class].natural_gas_intensity,
                  :fuel_oil      => characteristics[:country_lodging_class].fuel_oil_intensity,
                  :electricity   => characteristics[:country_lodging_class].electricity_intensity,
                  :district_heat => characteristics[:country_lodging_class].district_heat_intensity
                }
            end
            
            # Otherwise look up the `country` lodging fuel intensities:
            #
            # - Natural gas intensity: *m<sup>3</sup> / room-night*
            # - Fuel oil intensity: *l / room-night*
            # - Electricity intensity: *kWh / room-night*
            # - District heat intensity: *MJ / room-night*
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                intensities = {
                  :natural_gas   => characteristics[:country].lodging_natural_gas_intensity,
                  :fuel_oil      => characteristics[:country].lodging_fuel_oil_intensity,
                  :electricity   => characteristics[:country].lodging_electricity_intensity,
                  :district_heat => characteristics[:country].lodging_district_heat_intensity
                }
                # Ignore the `country` fuel intensities if they're all blank.
                intensities.values.compact.empty? ? nil : intensities
            end
            
            # Otherwise look up global average lodging fuel intensities:
            #
            # - Natural gas intensity: *m<sup>3</sup> / room-night*
            # - Fuel oil intensity: *l / room-night*
            # - Electricity intensity: *kWh / room-night*
            # - District heat intensity: *MJ / room-night*
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                country_fallback = Country.fallback
                {
                  :natural_gas   => country_fallback.lodging_natural_gas_intensity,
                  :fuel_oil      => country_fallback.lodging_fuel_oil_intensity,
                  :electricity   => country_fallback.lodging_electricity_intensity,
                  :district_heat => country_fallback.lodging_district_heat_intensity
                }
            end
          end
          
          #### Cohort
          # *A set of responses from the [EIA Commercial Buildings Energy Consumption Survey](http://data.brighterplanet.com/commercial_building_energy_consumption_survey_responses) that represent buildings similar to the lodging property.*
          committee :cohort do
            # If the lodging is in the United States and we know `rooms range` or `census division`, assemble a cohort of CBECS responses:
            # Start with all responses, and then select only the responses that match `country lodging class`, `rooms range`, `census region`, and `cenusus division`.
            # If fewer than 8 responses match all of those characteristics, drop the last characteristic (initially `census division`) and try again.
            # Continue until we have 8 or more responses or we've dropped all the characteristics.
            quorum 'from country and input', :needs => :country, :appreciates => [:country_lodging_class, :rooms_range, :census_division],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                if characteristics[:country].iso_3166_code == 'US' and [characteristics[:rooms_range], characteristics[:census_division]].any?
=begin
                  lodging class is almost always better predictor of electricity or nat gas than census region
                  lodging class is usually better predictor of electricity or nat gas than census division
                  rooms is often a better predictor of electricity or nat gas than census region
=end
                  provided_characteristics = []
                  if country_lodging_class = characteristics[:country_lodging_class]
                    provided_characteristics << [:detailed_activity, country_lodging_class.cbecs_detailed_activity]
                  end
=begin
                  FIXME TODO shouldn't have to call :value on :rooms_range
=end
                  if rooms_range = characteristics[:rooms_range]
                    provided_characteristics << [:lodging_rooms, rooms_range.value]
                  end
                  if census_division = characteristics[:census_division]
                    provided_characteristics << [:census_region_number, census_division.census_region_number]
                    provided_characteristics << [:census_division_number, census_division.number]
                  end
                  
                  cohort = CommercialBuildingEnergyConsumptionSurveyResponse.where(:detailed_activity => ['Hotel', 'Motel or inn']).strict_cohort(*provided_characteristics)
                  
                  cohort unless cohort.none?
                end
            end
          end
          
          #### Rooms range
          # *A range in the number of `property rooms`, used to look up similar buildings from the [EIA Commercial Buildings Energy Consumption Survey](http://data.brighterplanet.com/commercial_building_energy_consumption_survey_responses).*
          committee :rooms_range do
            # Construct a range based on `property rooms` and `country lodging class`.
            quorum 'from property rooms and country lodging class', :needs => [:property_rooms, :country_lodging_class],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                case characteristics[:country_lodging_class].name
                when 'US Hotel'
                  case characteristics[:property_rooms]
                  when 1..200
                    [1, characteristics[:property_rooms] - 25].max..[35, characteristics[:property_rooms] + 25].max
                  when 201..350
                    (characteristics[:property_rooms] - 50)..(characteristics[:property_rooms] + 50)
                  when 351..425
                    (characteristics[:property_rooms] - 75)..(characteristics[:property_rooms] + 75)
                  else
                    400..9999
                  end
                when 'US Motel', 'US Inn'
                  case characteristics[:property_rooms]
                  when 1..50
                    [1, characteristics[:property_rooms] - 10].max..(characteristics[:property_rooms] + 10)
                  when 50..100
                    (characteristics[:property_rooms] - 20)..(characteristics[:property_rooms] + 20)
                  when 101..125
                    (characteristics[:property_rooms] - 40)..(characteristics[:property_rooms] + 40)
                  else
                    100..9999
                  end
                end
            end
            
            # Otherwise, construct a range based on `property rooms`.
            quorum 'from property rooms', :needs => :property_rooms,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                case characteristics[:property_rooms]
                when 1..50
                  [1, characteristics[:property_rooms] - 10].max..(characteristics[:property_rooms] + 10)
                when 50..100
                  (characteristics[:property_rooms] - 20)..(characteristics[:property_rooms] + 20)
                when 101..200
                  (characteristics[:property_rooms] - 25)..(characteristics[:property_rooms] + 25)
                when 201..350
                  (characteristics[:property_rooms] - 50)..(characteristics[:property_rooms] + 50)
                when 351..425
                  (characteristics[:property_rooms] - 75)..(characteristics[:property_rooms] + 75)
                else
                  400..9999
                end
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
            # Use client input, if available.
            
            # Otherwise use a custom matching algorithm to look up a lodging property based on user inputs.
            quorum "from custom matching algorithm", :needs => :lodging_property_name, :appreciates => [:zip_code, :city, :state, :country],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                LodgingProperty.better_match characteristics
            end
=begin
            CAREFUL! there isn't a test for the custom algorithm quorum
=end
          end
          
          #### Lodging property name
          # *The name of the property where the stay occurred.*
          #
          # Use client input, if available
          
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
=begin
                FIXME TODO user-input date should already be coerced
=end
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
