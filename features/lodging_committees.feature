Feature: Lodging Committee Calculations
  The lodging model should generate correct committee calculations

  Background:
    Given a Lodging

  Scenario: Date committee from timeframe
    Given a characteristic "timeframe" of "2009-06-06/2010-01-01"
    When the "date" committee reports
    Then the committee should have used quorum "from timeframe"
    And the conclusion of the committee should be "2009-06-06"
    And the conclusion should comply with standards "ghg_protocol_scope_3, iso"

  Scenario: Rooms committee from default
    When the "rooms" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1.0"

  Scenario: Duration committee from default
    When the "duration" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "86400"

  Scenario: Room nights committee from default
    Given a characteristic "timeframe" of "2009-06-06/2010-01-01"
    When the "date" committee reports
    And the "rooms" committee reports
    And the "duration" committee reports
    And the "room_nights" committee reports
    Then the committee should have used quorum "from rooms, duration, date, and timeframe"
    And the conclusion of the committee should be "1"

  Scenario Outline: Room nights committee from rooms, duration, date, and timeframe
    Given characteristic "date" of "<date>"
    And a characteristic "timeframe" of "<timeframe>"
    And a characteristic "rooms" of "<rooms>"
    And a characteristic "duration" of "<duration>"
    When the "room_nights" committee reports
    Then the committee should have used quorum "from rooms, duration, date, and timeframe"
    And the conclusion of the committee should be "<room_nights>"
    Examples:
      | date       | timeframe             | rooms | duration | room_nights |
      | 2009-01-15 | 2009-01-01/2009-02-01 | 2     | 172800   | 4           |
      | 2009-02-15 | 2009-01-01/2009-02-01 | 2     | 172800   | 0           |

  Scenario Outline: Location committee from geocodeable location description
    Given a characteristic "location_description" of address value "<address>"
    And the geocoder will encode the location_description as "<geocode>" with zip code "<zip>", state "<state>", and country "<country>"
    When the "location" committee reports
    Then the committee should have used quorum "from location description"
    And the conclusion of the committee should have "ll" of "<location>"
    And the conclusion should comply with standards "ghg_protocol_scope_3, iso"
    Examples:
      | address           | geocode                 | zip   | state | country | location                |
      | 05753             | 44.0229305,-73.1450146  | 05753 | VT    | US      | 44.0229305,-73.1450146  |
      | San Francisco, CA | 37.7749295,-122.4194155 |       | CA    | US      | 37.7749295,-122.4194155 |
      | Los Angeles, CA   | 34.0522342,-118.2436849 |       | CA    | US      | 34.0522342,-118.2436849 |
      | London, UK        | 51.5001524,-0.1262362   |       |       | GB      | 51.5001524,-0.1262362   |

  Scenario: Location committee from non-geocodeable location description
    Given a characteristic "location_description" of "Bag End, Hobbiton, Westfarthing, The Shire, Eriador, Middle Earth"
    And the geocoder will fail to encode the location_description
    When the "location" committee reports
    Then the conclusion of the committee should be nil

  Scenario: Zip code committee from location
    Given a characteristic "location_description" of address value "94122"
    And the geocoder will encode the location_description as "" with zip code "94122", state "CA", and country "US"
    When the "location" committee reports
    And the "zip_code" committee reports
    Then the committee should have used quorum "from location"
    And the conclusion of the committee should have "name" of "94122"

  Scenario: Zip code committee from location without zip
    Given a characteristic "location_description" of address value "San Francisco, CA"
    And the geocoder will encode the location_description as "" with zip code "", state "CA", and country "US"
    When the "location" committee reports
    And the "zip_code" committee reports
    Then the conclusion of the committee should be nil

  Scenario: State committee from location
    Given a characteristic "location_description" of address value "San Francisco, CA"
    And the geocoder will encode the location_description as "" with zip code "", state "CA", and country "US"
    When the "location" committee reports
    And the "state" committee reports
    Then the committee should have used quorum "from location"
    And the conclusion of the committee should have "postal_abbreviation" of "CA"

  Scenario: State committee from location without state
    Given a characteristic "location_description" of address value "London, UK"
    And the geocoder will encode the location_description as "" with zip code "", state "", and country "GB"
    When the "location" committee reports
    And the "state" committee reports
    Then the conclusion of the committee should be nil

  Scenario: State committee from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "state" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "postal_abbreviation" of "CA"

  Scenario: Census division committee from state
    Given a characteristic "state.postal_abbreviation" of "CA"
    When the "census_division" committee reports
    Then the committee should have used quorum "from state"
    And the conclusion of the committee should have "number" of "9"

  Scenario: Census region committee from census division
    Given a characteristic "census_division.number" of "9"
    When the "census_region" committee reports
    Then the committee should have used quorum "from census division"
    And the conclusion of the committee should have "name" of "West Region"

  Scenario: Country committee from state
    Given a characteristic "state.postal_abbreviation" of "CA"
    When the "country" committee reports
    Then the committee should have used quorum "from state"
    And the conclusion of the committee should have "iso_3166_code" of "US"

  Scenario Outline: Country committee from location
    Given a characteristic "location_description" of address value "<address>"
    And the geocoder will encode the location_description as "" with zip code "", state "", and country "<country>"
    When the "location" committee reports
    And the "country" committee reports
    Then the committee should have used quorum "from location"
    And the conclusion of the committee should have "iso_3166_code" of "<country>"
    Examples:
      | address           | country |
      | San Francisco, CA | US      |
      | London, UK        | GB      |

  Scenario: eGRID subregion from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "egrid_subregion" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "abbreviation" of "CAMX"

  Scenario: Country lodging class committee from valid country and lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    And a characteristic "country.iso_3166_code" of "US"
    When the "country_lodging_class" committee reports
    Then the conclusion of the committee should have "name" of "US Hotel"

  Scenario: Country lodging class committee from invalid country and lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    And a characteristic "country.iso_3166_code" of "GB"
    When the "country_lodging_class" committee reports
    Then the conclusion of the committee should be nil

  Scenario: District heat intensity committee from default
    When the "district_heat_intensity" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "2.3"

  Scenario: District heat intensity committee from country without intensity
    Given a characteristic "country.iso_3166_code" of "GB"
    When the "district_heat_intensity" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "2.3"

  Scenario: District heat intensity committee from country with intensity
    Given a characteristic "country.iso_3166_code" of "VI"
    When the "district_heat_intensity" committee reports
    Then the committee should have used quorum "from country"
    And the conclusion of the committee should be "2.5"

  Scenario: District heat intensity committee from country lodging class
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "lodging_class.name" of "Hotel"
    When the "country_lodging_class" committee reports
    And the "district_heat_intensity" committee reports
    Then the committee should have used quorum "from country lodging class"
    And the conclusion of the committee should be "2.3"

  Scenario: District heat intensity committee from census division
    Given a characteristic "census_division.number" of "9"
    When the "district_heat_intensity" committee reports
    Then the committee should have used quorum "from census division"
    And the conclusion of the committee should be "2.3"

  Scenario: Electricity intensity committee from default
    When the "electricity_intensity" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "55.0"

  Scenario: Electricity intensity committee from country without intensity
    Given a characteristic "country.iso_3166_code" of "GB"
    When the "electricity_intensity" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "55.0"

  Scenario: Electricity intensity committee from country with intensity
    Given a characteristic "country.iso_3166_code" of "VI"
    When the "electricity_intensity" committee reports
    Then the committee should have used quorum "from country"
    And the conclusion of the committee should be "60.0"

  Scenario: Electricity intensity committee from country lodging class
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "lodging_class.name" of "Hotel"
    When the "country_lodging_class" committee reports
    And the "electricity_intensity" committee reports
    Then the committee should have used quorum "from country lodging class"
    And the conclusion of the committee should be "55.0"

  Scenario: Census region lodging class committee from valid census region and lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    And a characteristic "census_region.number" of "4"
    When the "census_region_lodging_class" committee reports
    Then the conclusion of the committee should have "name" of "West Hotel"

  Scenario: Electricity intensity committee from census division
    Given a characteristic "census_division.number" of "9"
    When the "electricity_intensity" committee reports
    Then the committee should have used quorum "from census division"
    And the conclusion of the committee should be "29.0"

  Scenario: Census region lodging class committee from invalid census region and lodging class
    Given a characteristic "lodging_class.name" of "Auberge"
    And a characteristic "census_region.number" of "4"
    When the "census_region_lodging_class" committee reports
    Then the conclusion of the committee should be nil

  Scenario: Fuel oil intensity committee from default
    When the "fuel_oil_intensity" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.3"

  Scenario: Fuel oil intensity committee from country without intensity
    Given a characteristic "country.iso_3166_code" of "GB"
    When the "fuel_oil_intensity" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.3"

  Scenario: Fuel oil intensity committee from country with intensity
    Given a characteristic "country.iso_3166_code" of "VI"
    When the "fuel_oil_intensity" committee reports
    Then the committee should have used quorum "from country"
    And the conclusion of the committee should be "0.5"

  Scenario: Fuel oil intensity committee from country lodging class
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "lodging_class.name" of "Hotel"
    When the "country_lodging_class" committee reports
    And the "fuel_oil_intensity" committee reports
    Then the committee should have used quorum "from country lodging class"
    And the conclusion of the committee should be "0.3"

  Scenario: Fuel oil intensity committee from census division
    Given a characteristic "census_division.number" of "9"
    When the "fuel_oil_intensity" committee reports
    Then the committee should have used quorum "from census division"
    And the conclusion of the committee should be "0.0"

  Scenario: Natural gas intensity committee from default
    When the "natural_gas_intensity" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "3.5"

  Scenario: Natural gas intensity committee from country without intensity
    Given a characteristic "country.iso_3166_code" of "GB"
    When the "natural_gas_intensity" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "3.5"

  Scenario: Natural gas intensity committee from country with intensity
    Given a characteristic "country.iso_3166_code" of "VI"
    When the "natural_gas_intensity" committee reports
    Then the committee should have used quorum "from country"
    And the conclusion of the committee should be "4.0"

  Scenario: Natural gas intensity committee from country lodging class
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "lodging_class.name" of "Hotel"
    When the "country_lodging_class" committee reports
    And the "natural_gas_intensity" committee reports
    Then the committee should have used quorum "from country lodging class"
    And the conclusion of the committee should be "3.5"

  Scenario: Natural gas intensity committee from census division
    Given a characteristic "census_division.number" of "9"
    When the "natural_gas_intensity" committee reports
    Then the committee should have used quorum "from census division"
    And the conclusion of the committee should be "1.6"

  Scenario: District heat use committee
    Given a characteristic "room_nights" of "4"
    When the "district_heat_intensity" committee reports
    And the "district_heat_use" committee reports
    Then the committee should have used quorum "from district heat intensity and room nights"
    And the conclusion of the committee should be "9.2"
    
  Scenario: Electricity use committee
    Given a characteristic "room_nights" of "4"
    When the "electricity_intensity" committee reports
    And the "electricity_use" committee reports
    Then the committee should have used quorum "from electricity intensity and room nights"
    And the conclusion of the committee should be "220.0"
    
  Scenario: Fuel oil use committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_oil_intensity" committee reports
    And the "fuel_oil_use" committee reports
    Then the committee should have used quorum "from fuel oil intensity and room nights"
    And the conclusion of the committee should be "1.0"
    
  Scenario: Natural gas use committee
    Given a characteristic "room_nights" of "4"
    When the "natural_gas_intensity" committee reports
    And the "natural_gas_use" committee reports
    Then the committee should have used quorum "from natural gas intensity and room nights"
    And the conclusion of the committee should be "14.0"

  Scenario: District heat emission factor committee
    When the "district_heat_emission_factor" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.07641"

  Scenario: Electricity emission factor committee from default
    When the "electricity_emission_factor" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.62783"

  Scenario: Electricity emission factor committee from country missing emission factor
    Given a characteristic "country.iso_3166_code" of "GB"
    When the "electricity_emission_factor" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.62783"

  Scenario: Electricity emission factor committee from country with emission factor
    Given a characteristic "country.iso_3166_code" of "US"
    When the "electricity_emission_factor" committee reports
    Then the committee should have used quorum "from country"
    And the conclusion of the committee should be "0.62783"

  Scenario: Electricity emission factor committee from eGRID subregion
    Given a characteristic "egrid_subregion.abbreviation" of "CAMX"
    When the "electricity_emission_factor" committee reports
    Then the committee should have used quorum "from eGRID subregion"
    And the conclusion of the committee should be "0.32632"
