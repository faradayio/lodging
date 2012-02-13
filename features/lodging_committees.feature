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

  # Scenario: Zip code committee from postcode that is zip code
  #   Given a characteristic "postcode" of "94122"
  #   When the "zip_code" committee reports
  #   Then the committee should have used quorum "from postcode"
  #   And the conclusion of the committee should have "name" of "94122"
  # 
  # Scenario: Zip code committee from postcode that is zip+4
  #   Given a characteristic "postcode" of "94122-1234"
  #   When the "zip_code" committee reports
  #   Then the committee should have used quorum "from postcode"
  #   And the conclusion of the committee should have "name" of "94122"
  # 
  # Scenario: Zip code committee from postcode that is not zip code
  #   Given a characteristic "postcode" of "38000"
  #   When the "zip_code" committee reports
  #   Then the conclusion of the committee should be nil

  Scenario: Climate division from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "climate_division" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "name" of "CA4"

  Scenario: Climate division from zip code missing climate division
    Given a characteristic "zip_code.name" of "94133"
    When the "climate_division" committee reports
    Then the conclusion of the committee should be nil

  Scenario: City committee from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "city" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should be "San Francisco"

  Scenario: State committee from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "state" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "postal_abbreviation" of "CA"

  Scenario: Country committee from state
    Given a characteristic "state.postal_abbreviation" of "CA"
    When the "country" committee reports
    Then the committee should have used quorum "from state"
    And the conclusion of the committee should have "iso_3166_code" of "US"

  Scenario: eGRID subregion from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "egrid_subregion" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "abbreviation" of "CAMX"

  Scenario: Cooling degree days committee from country
    Given a characteristic "country.iso_3166_code" of "US"
    When the "cooling_degree_days" committee reports
    Then the committee should have used quorum "from country"
    And the conclusion of the committee should be "880"

  Scenario: Cooling degree days committee from climate division
    Given a characteristic "climate_division.name" of "CA4"
    When the "cooling_degree_days" committee reports
    Then the committee should have used quorum "from climate division"
    And the conclusion of the committee should be "150"

  Scenario: Heating degree days committee from country
    Given a characteristic "country.iso_3166_code" of "US"
    When the "heating_degree_days" committee reports
    Then the committee should have used quorum "from country"
    And the conclusion of the committee should be "2200"

  Scenario: Heating degree days committee from climate division
    Given a characteristic "climate_division.name" of "CA4"
    When the "heating_degree_days" committee reports
    Then the committee should have used quorum "from climate division"
    And the conclusion of the committee should be "1350"

  Scenario: Property floors from property
    Given a characteristic "property.northstar_id" of "1"
    When the "property_floors" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "2"

  Scenario: Property construction year from property
    Given a characteristic "property.northstar_id" of "1"
    When the "property_construction_year" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "2002"

  Scenario: Property ac coverage from property
    Given a characteristic "property.northstar_id" of "1"
    When the "property_ac_coverage" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "1.0"

  Scenario: Lodging class from property
    Given a characteristic "property.northstar_id" of "3"
    When the "lodging_class" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should have "name" of "Inn"

  Scenario: Country lodging class committee from valid country and lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    And a characteristic "country.iso_3166_code" of "US"
    When the "country_lodging_class" committee reports
    Then the conclusion of the committee should have "name" of "US Hotel"

  Scenario: Country lodging class committee from invalid country and lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    And a characteristic "country.iso_3166_code" of "VI"
    When the "country_lodging_class" committee reports
    Then the conclusion of the committee should be nil

  Scenario: Fuel intensities committee from default
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should include a key of "natural_gas" and value "2.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.4"
    And the conclusion of the committee should include a key of "electricity" and value "33.9"
    And the conclusion of the committee should include a key of "district_heat" and value "1.8"

  Scenario: Fuel intensities committee from country missing intensities
    Given a characteristic "country.iso_3166_code" of "VI"
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should include a key of "natural_gas" and value "2.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.4"
    And the conclusion of the committee should include a key of "electricity" and value "33.9"
    And the conclusion of the committee should include a key of "district_heat" and value "1.8"

  Scenario: Fuel intensities committee from country with intensities
    Given a characteristic "country.iso_3166_code" of "GB"
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "from country"
    And the conclusion of the committee should include a key of "natural_gas" and value "3.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.5"
    And the conclusion of the committee should include a key of "electricity" and value "60.0"
    And the conclusion of the committee should include a key of "district_heat" and value "0.0"

  Scenario: Fuel intensities committee from country lodging class
    Given a characteristic "country.iso_3166_code" of "GB"
    And a characteristic "lodging_class.name" of "Hotel"
    When the "country_lodging_class" committee reports
    And the "fuel_intensities" committee reports
    Then the committee should have used quorum "from country lodging class"
    And the conclusion of the committee should include a key of "natural_gas" and value "4.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "1.0"
    And the conclusion of the committee should include a key of "electricity" and value "65.0"
    And the conclusion of the committee should include a key of "district_heat" and value "0.0"

  Scenario Outline: Fuel intensities committee from fuzzy weighting
    Given a characteristic "heating_degree_days" of "<hdd>"
    And a characteristic "cooling_degree_days" of "<cdd>"
    And a characteristic "property_rooms" of "<rooms>"
    And a characteristic "property_floors" of "<floors>"
    And a characteristic "property_construction_year" of "<year>"
    And a characteristic "property_ac_coverage" of "<ac>"
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "from degree days and user inputs"
    And the conclusion of the committee should include a key of "natural_gas" and value "<gas>"
    And the conclusion of the committee should include a key of "fuel_oil" and value "<oil>"
    And the conclusion of the committee should include a key of "electricity" and value "<elec>"
    And the conclusion of the committee should include a key of "disrict_heat" and value "<steam>"
    Examples:
     | hdd  | cdd | rooms | floors | year | ac  | gas | oil | elec | steam |
     | 1350 | 150 | 100   | 3      | 1993 | 0.5 | 0   | 0   | 0    | 0     |
     | 2200 | 880 | 100   | 3      | 1993 | 0.5 | 0   | 0   | 0    | 0     |
     | 2800 |  60 | 100   | 3      | 1993 | 0.5 | 0   | 0   | 0    | 0     |

  Scenario: District heat use committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "district_heat_use" committee reports
    Then the committee should have used quorum "from fuel intensities and room nights"
    And the conclusion of the committee should be "7.2"
    
  Scenario: Electricity use committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "electricity_use" committee reports
    Then the committee should have used quorum "from fuel intensities and room nights"
    And the conclusion of the committee should be "135.6"
    
  Scenario: Fuel oil use committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "fuel_oil_use" committee reports
    Then the committee should have used quorum "from fuel intensities and room nights"
    And the conclusion of the committee should be "1.6"
    
  Scenario: Natural gas use committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "natural_gas_use" committee reports
    Then the committee should have used quorum "from fuel intensities and room nights"
    And the conclusion of the committee should be "8.0"

  Scenario: Electricity emission factor committee from default
    When the "electricity_emission_factor" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.69252"

  Scenario: Electricity emission factor committee from country missing emission factor
    Given a characteristic "country.iso_3166_code" of "VI"
    When the "electricity_emission_factor" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.69252"

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
