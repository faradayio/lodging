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
    Given a characteristic "lodging_class.name" of "Motel or inn"
    And a characteristic "country.iso_3166_code" of "US"
    When the "country_lodging_class" committee reports
    Then the conclusion of the committee should have "name" of "US Motel or inn"

  Scenario: Country lodging class committee from invalid country and lodging class
    Given a characteristic "lodging_class.name" of "Motel or inn"
    And a characteristic "country.iso_3166_code" of "GB"
    When the "country_lodging_class" committee reports
    Then the conclusion of the committee should be nil

  Scenario Outline: rooms range committee from building rooms
    Given a characteristic "building_rooms" of "<rooms>"
    When the "rooms_range" committee reports
    Then the committee should have used quorum "from building rooms"
    And the conclusion of the committee should be "<range>"
    Examples:
      | rooms | range     |
      | 7     | 1..17     |
      | 20    | 10..30    |
      | 140   | 115..165  |
      | 300   | 250..350  |
      | 391   | 316..466  |
      | 502   | 400..9999 |

  Scenario Outline: rooms range committee from building rooms and lodging class
    Given a characteristic "lodging_class.name" of "<class>"
    And a characteristic "building_rooms" of "<rooms>"
    When the "rooms_range" committee reports
    Then the committee should have used quorum "from building rooms and lodging class"
    And the conclusion of the committee should be "<range>"
    Examples:
      | class        | rooms | range     |
      | Hotel        | 7     | 1..35     |
      | Hotel        | 50    | 25..75    |
      | Hotel        | 300   | 250..350  |
      | Hotel        | 420   | 345..495  |
      | Hotel        | 720   | 400..9999 |
      | Motel or inn | 2     | 1..12     |
      | Motel or inn | 42    | 32..52    |
      | Motel or inn | 73    | 53..93    |
      | Motel or inn | 111   | 71..151   |
      | Motel or inn | 130   | 100..9999 |

  Scenario Outline: cohort committee from various characteristics
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "lodging_class.name" of "<class>"
    And a characteristic "building_rooms" of "<rooms>"
    And a characteristic "census_region.number" of "<region>"
    And a characteristic "census_division.number" of "<division>"
    When the "rooms_range" committee reports
    And the "cohort" committee reports
    Then the committee should have used quorum "from country and input"
    And the conclusion of the committee should have a record with "count" equal to "<records>"
    Examples:
      | class        | rooms | region | division | records | notes |
      | Hotel        | 50    | 4      | 9        | 8       | class, rooms, and division |
      | Motel or inn | 20    | 4      | 9        | 8       | class |

  Scenario: cohort committee from various characteristics
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "building_rooms" of "20"
    And a characteristic "census_region.number" of "4"
    And a characteristic "census_division.number" of "9"
    When the "rooms_range" committee reports
    And the "cohort" committee reports
    Then the committee should have used quorum "from country and input"
    And the conclusion of the committee should have a record with "count" equal to "8"

  Scenario Outline: cohort committee from insufficient characteristics
    Given a characteristic "country.iso_3166_code" of "<country>"
    And a characteristic "building_rooms" of "<rooms>"
    And a characteristic "census_region.number" of "<region>"
    And a characteristic "census_division.number" of "<division>"
    When the "rooms_range" committee reports
    And the "cohort" committee reports
    Then the conclusion of the committee should be nil
    Examples:
      | country | rooms | notes |
      | US      | 75    | not enough records |
      | GB      | 15    | not in US |

  Scenario: Fuel intensities committee from default
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should include a key of "natural_gas" and value "2.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.42"
    And the conclusion of the committee should include a key of "electricity" and value "33.9"
    And the conclusion of the committee should include a key of "district_heat" and value "1.8"

  Scenario: Fuel intensities committee from country missing intensities
    Given a characteristic "country.iso_3166_code" of "GB"
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should include a key of "natural_gas" and value "2.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.42"
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
    And a characteristic "building_rooms" of "<rooms>"
    And a characteristic "census_region.number" of "<region>"
    And a characteristic "census_division.number" of "<division>"
    When the "rooms_range" committee reports
    And the "cohort" committee reports
    And the "fuel_intensities" committee reports
    Then the committee should have used quorum "from cohort"
    And the conclusion of the committee should include a key of "natural_gas" and value "<natural_gas>"
    And the conclusion of the committee should include a key of "fuel_oil" and value "<fuel_oil>"
    And the conclusion of the committee should include a key of "electricity" and value "<electricity>"
    And the conclusion of the committee should include a key of "district_heat" and value "<district_heat>"
    Examples:
      | class        | rooms | region | division | natural_gas | fuel_oil | electricity | district_heat | notes |
      | Hotel        | 50    | 4      | 9        | 2.53177     | 0.0      | 29.69253    | 0.0           | class rooms division |
      | Motel or inn | 20    | 4      | 9        | 1.57069     | 0.46650  | 27.69965    | 1.62346       | class |

  Scenario: Fuel intensities committee from cohort (based on rooms and region)
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "building_rooms" of "20"
    And a characteristic "census_region.number" of "4"
    And a characteristic "census_division.number" of "9"
    When the "rooms_range" committee reports
    And the "cohort" committee reports
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
    And the conclusion of the committee should be "1.68"
    
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
