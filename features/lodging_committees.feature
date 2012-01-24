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

  Scenario: Climate division committee from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "climate_division" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "name" of "CA4"

  Scenario: Climate zone number committee from climate division
    Given a characteristic "climate_division.name" of "CA4"
    When the "climate_zone_number" committee reports
    Then the committee should have used quorum "from climate division"
    And the conclusion of the committee should be "4"

  Scenario: Climate zone number committee from state
    Given a characteristic "state.postal_abbreviation" of "MI"
    When the "climate_zone_number" committee reports
    Then the committee should have used quorum "from state"
    And the conclusion of the committee should be "1"

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

  Scenario: Lodging class committee from lodging property
    Given a characteristic "lodging_property.northstar_id" of "3"
    When the "lodging_class" committee reports
    Then the committee should have used quorum "from lodging property"
    And the conclusion of the committee should have "name" of "Inn"

  Scenario: Country lodging class committee from known country and lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    And a characteristic "country.iso_3166_code" of "US"
    When the "country_lodging_class" committee reports
    Then the conclusion of the committee should have "name" of "US Hotel"

  Scenario: Country lodging class committee from unknown country and lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    And a characteristic "country.iso_3166_code" of "GB"
    When the "country_lodging_class" committee reports
    Then the conclusion of the committee should be nil

  Scenario: Property rooms from lodging property
    Given a characteristic "lodging_property.northstar_id" of "3"
    When the "property_rooms" committee reports
    Then the committee should have used quorum "from lodging property"
    And the conclusion of the committee should be "25"

  Scenario: property construction year from lodging property
    Given a characteristic "lodging_property.northstar_id" of "1"
    When the "property_construction_year" committee reports
    Then the committee should have used quorum "from lodging property"
    And the conclusion of the committee should be "1995"

  Scenario Outline: lodging properties cohort committee from various characteristics
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "lodging_class.name" of "<class>"
    And a characteristic "census_division.number" of "<division>"
    When the "country_lodging_class" committee reports
    And the "lodging_properties_cohort" committee reports
    Then the committee should have used quorum "from census division and input"
    And the conclusion of the committee should have a record with "count" equal to "<records>"
    Examples:
      | class | division | records | notes |
      | Hotel | 9        | 8       | class and division |
      | Inn   | 9        | 11      | region |

  Scenario: Fuel intensities committee from default
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should include a key of "natural_gas" and value "2.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.4"
    And the conclusion of the committee should include a key of "electricity" and value "33.9"
    And the conclusion of the committee should include a key of "steam" and value "1.8"

  Scenario: Fuel intensities committee from country missing intensities
    Given a characteristic "country.iso_3166_code" of "GB"
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should include a key of "natural_gas" and value "2.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.4"
    And the conclusion of the committee should include a key of "electricity" and value "33.9"
    And the conclusion of the committee should include a key of "steam" and value "1.8"

  Scenario: Fuel intensities committee from country with intensities
    Given a characteristic "country.iso_3166_code" of "VI"
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "from country"
    And the conclusion of the committee should include a key of "natural_gas" and value "3.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.5"
    And the conclusion of the committee should include a key of "electricity" and value "60.0"
    And the conclusion of the committee should include a key of "steam" and value "0.0"

  Scenario: Fuel intensities committee from country lodging class
    Given a characteristic "country.iso_3166_code" of "VI"
    And a characteristic "lodging_class.name" of "Hotel"
    When the "country_lodging_class" committee reports
    And the "fuel_intensities" committee reports
    Then the committee should have used quorum "from country lodging class"
    And the conclusion of the committee should include a key of "natural_gas" and value "4.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "1.0"
    And the conclusion of the committee should include a key of "electricity" and value "65.0"
    And the conclusion of the committee should include a key of "steam" and value "0.0"

  Scenario Outline: Fuel intensities committee from cohort
    Given a characteristic "country.iso_3166_code" of "US"
    And a characteristic "lodging_class.name" of "<class>"
    And a characteristic "census_division.number" of "<division>"
    When the "country_lodging_class" committee reports
    And the "lodging_properties_cohort" committee reports
    And the "fuel_intensities" committee reports
    Then the committee should have used quorum "from cohort"
    And the conclusion of the committee should include a key of "natural_gas" and value "<gas>"
    And the conclusion of the committee should include a key of "fuel_oil" and value "<oil>"
    And the conclusion of the committee should include a key of "electricity" and value "<electricity>"
    And the conclusion of the committee should include a key of "steam" and value "<steam>"
    Examples:
      | class | division | gas     | oil     | electricity | steam    | notes |
      | Hotel | 9        | 2.54366 | 0.34311 | 54.43335    | 21.30898 | class division |
      | Inn   | 9        | 2.40316 | 0.06645 | 36.90214    | 4.06173  | region |

  Scenario Outline: electricity use equation from various characteristics
    Given a characteristic "climate_zone_number" of "<zone>"
    And a characteristic "property_rooms" of "<rooms>"
    And a characteristic "property_construction_year" of "<year>"
    When the "electricity_use_equation" committee reports
    Then the committee should have used quorum "from available characteristics"
    And the conclusion of the committee should have "name" of "<equation>"
    Examples:
      | zone | rooms | year | equation                      |
      | 4    | 24    | 1923 | Electricity zone 4 rooms year |
      | 4    | 24    |      | Electricity zone 4 rooms      |
      | 4    |       | 1923 | Electricity zone 4 year       |
      | 4    |       |      | Electricity zone 4            |
      |      | 24    | 1923 | Electricity rooms year        |
      |      | 24    |      | Electricity rooms             |
      |      |       | 1923 | Electricity year              |

  Scenario Outline: fuels use equation from various characteristics
    Given a characteristic "climate_zone_number" of "<zone>"
    And a characteristic "property_rooms" of "<rooms>"
    And a characteristic "property_construction_year" of "<year>"
    When the "fuels_use_equation" committee reports
    Then the committee should have used quorum "from available characteristics"
    And the conclusion of the committee should have "name" of "<equation>"
    Examples:
      | zone | rooms | year | equation                |
      | 4    | 25    | 1910 | Fuels zone 4 rooms year |
      | 4    | 25    |      | Fuels zone 4 rooms      |
      | 4    |       | 1910 | Fuels zone 4 year       |
      | 4    |       |      | Fuels zone 4            |
      |      | 25    | 1910 | Fuels rooms year        |
      |      | 25    |      | Fuels rooms             |
      |      |       | 1910 | Fuels year              |

  Scenario: Electricity use committee from fuel intensities
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "electricity_use" committee reports
    Then the committee should have used quorum "from fuel intensities and room nights"
    And the conclusion of the committee should be "135.6"

  Scenario Outline: Electricity use committee from electricity use equation
    Given a characteristic "room_nights" of "4"
    And a characteristic "climate_zone_number" of "<zone>"
    And a characteristic "property_rooms" of "<rooms>"
    And a characteristic "property_construction_year" of "<year>"
    When the "electricity_use_equation" committee reports
    And the "electricity_use" committee reports
    Then the committee should have used quorum "from electricity use equation, room nights, and inputs"
    And the conclusion of the committee should be "<elec>"
    Examples:
      | zone | rooms | year | elec      |
      | 4    |       |      | 101.88324 |
      | 4    | 25    | 1910 |  74.45070 |
      | 4    | 25    |      |  82.40524 |
      | 4    |       | 1910 | 101.87391 |
      |      | 25    | 1910 |  24.17331 |
      |      | 25    |      |  94.62947 |
      |      |       | 1910 |  30.56217 |
      | 4    | 75    | 1983 | 143.90199 |
      | 4    | 75    |      |  95.71974 |
      | 4    |       | 1983 | 195.93775 |
      |      | 75    | 1983 |  47.79044 |
      |      | 75    |      | 104.57130 |
      |      |       | 1983 |  58.78133 |
      | 4    | 500   | 2011 | 624.86834 |
      | 4    | 500   |      | 341.89915 |
      | 4    |       | 2011 | 251.80873 |
      |      | 500   | 2011 | 139.64249 |
      |      | 500   |      | 244.45231 |
      |      |       | 2011 |  75.54262 |

  Scenario: Fuel oil use committee from fuel intensities
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "fuel_oil_use" committee reports
    Then the committee should have used quorum "from fuel intensities and room nights"
    And the conclusion of the committee should be "1.71788"

  Scenario Outline: Fuel oil use committee from fuels use equation
    Given a characteristic "room_nights" of "4"
    And a characteristic "climate_zone_number" of "<zone>"
    And a characteristic "property_rooms" of "<rooms>"
    And a characteristic "property_construction_year" of "<year>"
    When the "fuels_use_equation" committee reports
    And the "fuel_oil_use" committee reports
    Then the committee should have used quorum "from fuels use equation, room nights, and inputs"
    And the conclusion of the committee should be "<fuel_oil>"
    Examples:
      | zone | rooms | year | fuel_oil |
      | 4    |       |      |  0.98748 |
      | 4    | 25    | 1910 |  1.37083 |
      | 4    | 25    |      |  0.91833 |
      | 4    |       | 1910 |  1.39994 |
      |      | 25    | 1910 |  7.05621 |
      |      | 25    |      |  4.07359 |
      |      |       | 1910 |  7.46357 |
      | 4    | 75    | 1983 |  0.85452 |
      | 4    | 75    |      |  1.02751 |
      | 4    |       | 1983 |  0.88631 |
      |      | 75    | 1983 |  3.61379 |
      |      | 75    |      |  4.72911 |
      |      |       | 1983 |  3.77205 |
      | 4    | 500   | 2011 |  1.64111 |
      | 4    | 500   |      |  1.95555 |
      | 4    |       | 2011 |  0.68930 |
      |      | 500   | 2011 |  8.75401 |
      |      | 500   |      | 10.30104 |
      |      |       | 2011 |  2.35613 |

  Scenario: Natural gas use committee from fuel intensities
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "natural_gas_use" committee reports
    Then the committee should have used quorum "from fuel intensities and room nights"
    And the conclusion of the committee should be "8.12206"

  Scenario Outline: Natural gas use committee from fuels use equation
    Given a characteristic "room_nights" of "4"
    And a characteristic "climate_zone_number" of "<zone>"
    And a characteristic "property_rooms" of "<rooms>"
    And a characteristic "property_construction_year" of "<year>"
    When the "fuels_use_equation" committee reports
    And the "natural_gas_use" committee reports
    Then the committee should have used quorum "from fuels use equation, room nights, and inputs"
    And the conclusion of the committee should be "<nat_gas>"
    Examples:
      | zone | rooms | year | nat_gas  |
      | 4    |       |      |  6.44794 |
      | 4    | 25    | 1910 |  8.95108 |
      | 4    | 25    |      |  5.99643 |
      | 4    |       | 1910 |  9.14119 |
      |      | 25    | 1910 | 12.57986 |
      |      | 25    |      |  7.26243 |
      |      |       | 1910 | 13.30611 |
      | 4    | 75    | 1983 |  5.57977 |
      | 4    | 75    |      |  6.70935 |
      | 4    |       | 1983 |  5.78731 |
      |      | 75    | 1983 |  6.44269 |
      |      | 75    |      |  8.43110 |
      |      |       | 1983 |  6.72484 |
      | 4    | 500   | 2011 | 10.71594 |
      | 4    | 500   |      | 12.76915 |
      | 4    |       | 2011 |  4.50089 |
      |      | 500   | 2011 | 15.60671 |
      |      | 500   |      | 18.36476 |
      |      |       | 2011 |  4.20052 |

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
