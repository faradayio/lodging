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
            # Sum the `eGRID subregion` electricity CO<sub>2</sub>, CH<sub>4</sub>, and N<sub>2</sub>O emission factors (*kg CO<sub>2</sub>e / kWh*) and divide by 1 minus the `eGRID region` loss factor (account for transmission and distribution losses) to give *kg CO<sub>2</sub>e / kWh*.
            quorum 'from eGRID subregion and eGRID region', :needs => [:egrid_subregion, :egrid_region],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                (
                  characteristics[:egrid_subregion].electricity_co2_emission_factor +
                  characteristics[:egrid_subregion].electricity_ch4_emission_factor +
                  characteristics[:egrid_subregion].electricity_n2o_emission_factor
                ) /
                (1 - characteristics[:egrid_region].loss_factor)
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
          # *A greenhous gas emission factor for district heat used by the lodging.*
          committee :district_heat_emission_factor do
            # Calculate an energy-based emission factor for [natural gas](http://data.brighterplanet.com/fuels) by dividing its CO<sub>2</sub> emission factor (*kg / m<sup>3</sup>*) by its energy content (*MJ / m<sup>3</sup>*) to give *kg CO<sub>2</sub> / MJ*.
            # Calculate an energy-based emission factor for [fuel oil](http://data.brighterplanet.com/fuels) by dividing its CO<sub>2</sub> emission factor (*kg / l*) by its energy content (*MJ / l*) to give *kg CO<sub>2</sub> / MJ*.
            # Divide the energy-based natural gas emission factor by 0.817 and the energy-based fuel oil emission factor by 0.846 (assumed boiler inefficiencies), average the two (assume 50-50 split between fuel oil and natural gas boilers) and divide by 0.95 (assumed transmission losses) to give *kg CO<sub>2</sub> / MJ*.
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                natural_gas = Fuel.find_by_name 'Pipeline Natural Gas'
                natural_gas_energy_ef = natural_gas.co2_emission_factor / natural_gas.energy_content
                
                fuel_oil = Fuel.find_by_name 'Distillate Fuel Oil No. 2'
                fuel_oil_energy_ef = fuel_oil.co2_emission_factor / fuel_oil.energy_content
                
                (((natural_gas_energy_ef / 0.817) + (fuel_oil_energy_ef / 0.846)) / 2.0) / 0.95
            end
          end
          
          #### Natural gas use (*m<sup>3</sup>*)
          # The lodging's natural gas use during `timeframe`.
          committee :natural_gas_use do
            # Multiply `room nights` (*occupied room-nights*) by `natural gas intensity` (*m<sup>3</sup> / occupied room-night*) to give *m<sup>3</sup>*.
            quorum 'from natural gas intensity and room nights', :needs => [:natural_gas_intensity, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:natural_gas_intensity]
            end
          end
          
          #### Fuel oil use (*l*)
          # The lodging's fuel oil use during `timeframe`.
          committee :fuel_oil_use do
            # Multiply `room nights` (*occupied room-nights*) by `fuel oil intensity` (*l / occupied room-night*) to give *l*.
            quorum 'from fuel oil intensity and room nights', :needs => [:fuel_oil_intensity, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:fuel_oil_intensity]
            end
          end
          
          #### Electricity use (*kWh*)
          # The lodging's electricity use during `timeframe`.
          committee :electricity_use do
            # Multiply `room nights` (*occupied room-nights*) by `electricity intensity` (*kWh / occupied room-night*) to give *kWh*.
            quorum 'from electricity intensity and room nights', :needs => [:electricity_intensity, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:electricity_intensity]
            end
          end
          
          #### District heat use (*MJ*)
          # The lodging's district heat use during `timeframe`.
          committee :district_heat_use do
            # Multiply `room nights` (*occupied room-nights*) by `district heat intensity` (*MJ / occupied room-night*) to give *MJ*.
            quorum 'from district heat intensity and room nights', :needs => [:district_heat_intensity, :room_nights],
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:room_nights] * characteristics[:district_heat_intensity]
            end
          end
          
          #### Natural gas intensity (*m<sup>3</sup> / room-night*)
          # *The lodging's natural gas use per occupied room night.*
          committee :natural_gas_intensity do
            # Look up the `census division` natural gas intensity (*m<sup>3</sup> / occupied room-night*).
            quorum 'from census division', :needs => :census_division,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:census_division].lodging_building_natural_gas_intensity
            end
            
            # Otherwise look up the `country lodging class` natural gas intensity (*m<sup>3</sup> / occupied room-night*).
            quorum 'from country lodging class', :needs => :country_lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country_lodging_class].natural_gas_intensity
            end
            
            # Otherwise look up the `country` lodging natural gas intensity (*m<sup>3</sup> / occupied room-night*).
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country].lodging_natural_gas_intensity
            end
            
            # Otherwise look up the global average lodging natural gas intensity (*m<sup>3</sup> / occupied room-night*)
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                Country.fallback.lodging_natural_gas_intensity
            end
          end
          
          #### Fuel oil intensity (*l / room-night*)
          # *The lodging's fuel oil use per occupied room night.*
          committee :fuel_oil_intensity do
            # Look up the `census division` fuel oil intensity (*l / occupied room-night*).
            quorum 'from census division', :needs => :census_division,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:census_division].lodging_building_fuel_oil_intensity
            end
            
            # Otherwise look up the `country lodging class` fuel oil intensity (*l / occupied room-night*).
            quorum 'from country lodging class', :needs => :country_lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country_lodging_class].fuel_oil_intensity
            end
            
            # Otherwise look up the `country` lodging fuel oil intensity (*l / occupied room-night*).
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country].lodging_fuel_oil_intensity
            end
            
            # Otherwise look up the global average lodging fuel oil intensity (*l / occupied room-night*)
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                Country.fallback.lodging_fuel_oil_intensity
            end
          end
          
          #### Electricity intensity (*kWh / occupied room-night*)
          # *The lodging's electricity use per occupied room night.*
          committee :electricity_intensity do
            # Look up the `census division` electricity intensity (*kWh / occupied room-night*).
            quorum 'from census division', :needs => :census_division,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:census_division].lodging_building_electricity_intensity
            end
            
            # Otherwise look up the `country lodging class` electricity intensity (*kWh / occupied room-night*).
            quorum 'from country lodging class', :needs => :country_lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country_lodging_class].electricity_intensity
            end
            
            # Otherwise look up the `country` lodging electricity intensity (*kWh / occupied room-night*).
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country].lodging_electricity_intensity
            end
            
            # Otherwise look up the global average lodging electricity intensity (*kWh / occupied room-night*)
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                Country.fallback.lodging_electricity_intensity
            end
          end
          
          #### District heat intensity (*MJ / occupied room-night*)
          # *The lodging's district heat use per occupied room night.*
          committee :district_heat_intensity do
            # Look up the `census division` district heat intensity (*MJ / occupied room-night*).
            quorum 'from census division', :needs => :census_division,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:census_division].lodging_building_district_heat_intensity
            end
            
            # Otherwise look up the `country lodging class` district heat intensity (*MJ / occupied room-night*).
            quorum 'from country lodging class', :needs => :country_lodging_class,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country_lodging_class].district_heat_intensity
            end
            
            # Otherwise look up the `country` lodging district heat intensity (*MJ / occupied room-night*).
            quorum 'from country', :needs => :country,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:country].lodging_district_heat_intensity
            end
            
            # Otherwise look up the global average lodging district heat intensity (*MJ / occupied room-night*)
            quorum 'default',
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do
                Country.fallback.lodging_district_heat_intensity
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
          #
          # Use client input, if available.
          
          #### eGRID region
          # *The lodging's [eGRID region](http://data.brighterplanet.com/egrid_regions).*
          committee :egrid_region do
            # Look up the `eGRID subregion` eGRID region.
            quorum 'from eGRID subregion', :needs => :egrid_subregion,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:egrid_subregion].egrid_region
            end
          end
          
          #### eGRID subregion
          # *The lodging's [eGRID subregion](http://data.brighterplanet.com/egrid_subregions).*
          committee :egrid_subregion do
            # Look up the `zip code` eGRID subregion.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].egrid_subregion
            end
          end
          
          #### Country
          # *The lodging's [country](http://data.brighterplanet.com/countries).*
          committee :country do
            # Look up the `location` country.
            quorum 'from location', :needs => :location,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                Country.find_by_iso_3166_code characteristics[:location].country_code
            end
          end
          
          #### Census division
          # *The lodging's [census division](http://data.brighterplanet.com/census_divisions).*
          committee :census_division do
            # Look up the `state` census division.
            quorum 'from state', :needs => :state,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:state].census_division
            end
          end
          
          #### State
          # *The lodging's [state](http://data.brighterplanet.com/states).*
          committee :state do
            # Use client input, if available.
            
            # Otherwise use the `zip code` state.
            quorum 'from zip code', :needs => :zip_code,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                characteristics[:zip_code].state
            end
            
            # Otherwise look up the `location` state.
            quorum 'from location', :needs => :location,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                State.find_by_postal_abbreviation characteristics[:location].state
            end
          end
          
          #### Zip code
          # *The lodging's [zip code](http://data.brighterplanet.com/zip_codes).*
          committee :zip_code do
            # Use client input, if available.
            
            # Otherwise look up the `location` zip code.
            quorum 'from location', :needs => :location,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                ZipCode.find_by_name characteristics[:location].zip
            end
          end
          
          #### Location (*lat, lng*)
          # *The lodging's location*.
          committee :location do
            # Use the [Geokit](http://geokit.rubyforge.org/) geocoder to look up the `location description` location (*lat, lng*).
            quorum 'from location description', :needs => :location_description,
              :complies => [:ghg_protocol_scope_3, :iso, :tcr] do |characteristics|
                location = ::Geokit::Geocoders::MultiGeocoder.geocode characteristics[:location_description]
                location.success ? location : nil
            end
          end
          
          #### Location description
          # *The client's description of the lodging's location (e.g. New York, NY, USA).*
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
