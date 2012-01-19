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

  Scenario: Census division committee from state
    Given a characteristic "state.postal_abbreviation" of "CA"
    When the "census_division" committee reports
    Then the committee should have used quorum "from state"
    And the conclusion of the committee should have "number" of "9"

  Scenario Outline: Lodging property committee from lodging property name, city, and state
    Given a characteristic "lodging_property_name" of "<name>"
    And a characteristic "city" of "<city>"
    And a characteristic "state.postal_abbreviation" of "<state>"
    When the "lodging_property" committee reports
    Then the committee should have used quorum "from lodging property name, city, and state"
    And the conclusion of the committee should have "name" of "<matched_name>"
    And the conclusion of the committee should have "northstar_id" of "<id>"
    Examples:
      | name                 | city          | state | matched_name         | id |
      | Hilton San Francisco | San Francisco | CA    | Hilton San Francisco | 1  |
      | Pacific Inn          | Daly City     | CA    | Pacific Inn          | 3  |

  Scenario Outline: Lodging property committee from lodging property name and zip code
    Given a characteristic "lodging_property_name" of "<name>"
    And a characteristic "zip_code.name" of "<zip>"
    When the "lodging_property" committee reports
    Then the committee should have used quorum "from lodging property name and zip code"
    And the conclusion of the committee should have "name" of "<matched_name>"
    And the conclusion of the committee should have "northstar_id" of "<id>"
    Examples:
      | name                 | zip   | matched_name         | id |
      | Hilton San Francisco | 94122 | Hilton San Francisco | 1  |
      | Pacific Inn          | 94014 | Pacific Inn          | 3  |

  Scenario: Lodging class from lodging property
    Given a characteristic "lodging_property.northstar_id" of "3"
    When the "lodging_class" committee reports
    Then the committee should have used quorum "from lodging property"
    And the conclusion of the committee should have "name" of "Inn"

  Scenario: Property rooms from lodging property
    Given a characteristic "lodging_property.northstar_id" of "3"
    When the "property_rooms" committee reports
    Then the committee should have used quorum "from lodging property"
    And the conclusion of the committee should be "25"

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

  Scenario Outline: rooms range committee from property rooms
    Given a characteristic "property_rooms" of "<rooms>"
    When the "rooms_range" committee reports
    Then the committee should have used quorum "from property rooms"
    And the conclusion of the committee should be "<range>"
    Examples:
      | rooms | range     |
      | 7     | 1..17     |
      | 20    | 10..30    |
      | 140   | 115..165  |
      | 300   | 250..350  |
      | 391   | 316..466  |
      | 502   | 400..9999 |

  Scenario Outline: rooms range committee from property rooms and country lodging class
    Given a characteristic "country.iso_3166_code" of "US"
    Given a characteristic "lodging_class.name" of "<class>"
    And a characteristic "property_rooms" of "<rooms>"
    When the "country_lodging_class" committee reports
    And the "rooms_range" committee reports
    Then the committee should have used quorum "from property rooms and country lodging class"
    And the conclusion of the committee should be "<range>"
    Examples:
      | class | rooms | range     |
      | Hotel | 7     | 1..35     |
      | Hotel | 50    | 25..75    |
      | Hotel | 300   | 250..350  |
      | Hotel | 420   | 345..495  |
      | Hotel | 720   | 400..9999 |
      | Inn   | 2     | 1..12     |
      | Inn   | 42    | 32..52    |
      | Inn   | 73    | 53..93    |
      | Inn   | 111   | 71..151   |
      | Inn   | 130   | 100..9999 |

  Scenario Outline: lodging properties cohort committee from various characteristics
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "lodging_class.name" of "<class>"
    And a characteristic "property_rooms" of "<rooms>"
    And a characteristic "census_division.number" of "<division>"
    When the "country_lodging_class" committee reports
    And the "rooms_range" committee reports
    And the "lodging_properties_cohort" committee reports
    Then the committee should have used quorum "from country and input"
    And the conclusion of the committee should have a record with "count" equal to "<records>"
    Examples:
      | class | rooms | division | records | notes |
      | Hotel | 50    | 9        | 8       | class, rooms, and division |
      | Inn   | 20    | 9        | 8       | class |

  Scenario Outline: lodging properties cohort committee from insufficient characteristics
    Given a characteristic "country.iso_3166_code" of "<country>"
    And a characteristic "property_rooms" of "<rooms>"
    When the "rooms_range" committee reports
    And the "lodging_properties_cohort" committee reports
    Then the conclusion of the committee should be nil
    Examples:
      | country | rooms | notes |
      | US      |       | not enough user inputs |
      | US      | 75    | not enough records |
      | GB      | 15    | not in US |

  Scenario: Fuel intensities committee from default
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should include a key of "natural_gas" and value "2.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.4"
    And the conclusion of the committee should include a key of "electricity" and value "33.9"
    And the conclusion of the committee should include a key of "district_heat" and value "1.8"

  Scenario: Fuel intensities committee from country missing intensities
    Given a characteristic "country.iso_3166_code" of "GB"
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should include a key of "natural_gas" and value "2.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.4"
    And the conclusion of the committee should include a key of "electricity" and value "33.9"
    And the conclusion of the committee should include a key of "district_heat" and value "1.8"

  Scenario: Fuel intensities committee from country with intensities
    Given a characteristic "country.iso_3166_code" of "VI"
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "from country"
    And the conclusion of the committee should include a key of "natural_gas" and value "3.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.5"
    And the conclusion of the committee should include a key of "electricity" and value "60.0"
    And the conclusion of the committee should include a key of "district_heat" and value "0.0"

  Scenario: Fuel intensities committee from country lodging class
    Given a characteristic "country.iso_3166_code" of "VI"
    And a characteristic "lodging_class.name" of "Hotel"
    When the "country_lodging_class" committee reports
    And the "fuel_intensities" committee reports
    Then the committee should have used quorum "from country lodging class"
    And the conclusion of the committee should include a key of "natural_gas" and value "4.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "1.0"
    And the conclusion of the committee should include a key of "electricity" and value "65.0"
    And the conclusion of the committee should include a key of "district_heat" and value "0.0"

  Scenario Outline: Fuel intensities committee from cohort
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "lodging_class.name" of "<class>"
    And a characteristic "property_rooms" of "<rooms>"
    And a characteristic "census_division.number" of "<division>"
    When the "country_lodging_class" committee reports
    And the "rooms_range" committee reports
    And the "lodging_properties_cohort" committee reports
    And the "fuel_intensities" committee reports
    Then the committee should have used quorum "from cohort"
    And the conclusion of the committee should include a key of "natural_gas" and value "<natural_gas>"
    And the conclusion of the committee should include a key of "fuel_oil" and value "<fuel_oil>"
    And the conclusion of the committee should include a key of "electricity" and value "<electricity>"
    And the conclusion of the committee should include a key of "district_heat" and value "<district_heat>"
    Examples:
      | class | rooms | division | natural_gas | fuel_oil | electricity | district_heat | notes |
      | Hotel | 50    | 9        | 2.53177     | 0.0      | 29.69253    | 0.0           | class rooms division |
      | Inn   | 20    | 9        | 1.57069     | 0.46650  | 27.69965    | 1.62346       | class |

  Scenario: Fuel intensities committee from cohort (based on rooms and region)
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "property_rooms" of "20"
    And a characteristic "census_division.number" of "9"
    When the "rooms_range" committee reports
    And the "lodging_properties_cohort" committee reports
    And the "fuel_intensities" committee reports
    Then the committee should have used quorum "from cohort"
    And the conclusion of the committee should include a key of "natural_gas" and value "3.11101"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.0"
    And the conclusion of the committee should include a key of "electricity" and value "22.24149"
    And the conclusion of the committee should include a key of "district_heat" and value "0.0"

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

  Scenario: District heat emission factor committee
    When the "district_heat_emission_factor" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.07641"

  Scenario: Electricity emission factor committee from default
    When the "electricity_emission_factor" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "0.69252"

  Scenario: Electricity emission factor committee from country missing emission factor
    Given a characteristic "country.iso_3166_code" of "GB"
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
