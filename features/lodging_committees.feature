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
    Then the committee should have used quorum "from electricity use equation and inputs"
    And the conclusion of the committee should be "<intensity>"
    Examples:
      | zone | rooms | year | intensity |
      | 4    | 25    | 1910 | 18.61268  |
      | 4    | 25    |      | 20.60131  |
      | 4    |       | 1910 | 25.46848  |
      | 4    |       |      | 25.47081  |
      |      | 25    | 1910 | 6.04333   |
      |      | 25    |      | 23.65737  |
      |      |       | 1910 | 7.64054   |
      | 4    | 75    | 1983 | 35.97550  |
      | 4    | 75    |      | 23.92993  |
      | 4    |       | 1983 | 48.98444  |
      | 4    |       |      | 25.47081  |
      |      | 75    | 1983 | 11.94761  |
      |      | 75    |      | 26.14282  |
      |      |       | 1983 | 14.69533  |
      | 4    | 500   | 2011 | 156.21709 |
      | 4    | 500   |      | 85.47479  |
      | 4    |       | 2011 | 62.95218  |
      | 4    |       |      | 25.47081  |
      |      | 500   | 2011 | 34.91062  |
      |      | 500   |      | 61.11308  |
      |      |       | 2011 | 18.88565  |

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
    Then the committee should have used quorum "from fuels use equation and inputs"
    And the conclusion of the committee should be "<intensity>"
    Examples:
      | zone | rooms | year | intensity |
      | 4    | 25    | 1910 | 0.34271   |
      | 4    | 25    |      | 0.22958   |
      | 4    |       | 1910 | 0.34999   |
      | 4    |       |      | 0.24687   |
      |      | 25    | 1910 | 1.76405   |
      |      | 25    |      | 1.01840   |
      |      |       | 1910 | 1.86589   |
      | 4    | 75    | 1983 | 0.21363   |
      | 4    | 75    |      | 0.25688   |
      | 4    |       | 1983 | 0.22158   |
      | 4    |       |      | 0.24687   |
      |      | 75    | 1983 | 0.90345   |
      |      | 75    |      | 1.18228   |
      |      |       | 1983 | 0.94301   |
      | 4    | 500   | 2011 | 0.41028   |
      | 4    | 500   |      | 0.48889   |
      | 4    |       | 2011 | 0.17232   |
      | 4    |       |      | 0.24687   |
      |      | 500   | 2011 | 2.18850   |
      |      | 500   |      | 2.57526   |
      |      |       | 2011 | 0.58903   |

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
    Then the committee should have used quorum "from fuels use equation and inputs"
    And the conclusion of the committee should be "<intensity>"
    Examples:
      | zone | rooms | year | intensity |
      | 4    | 25    | 1910 | 2.23777   |
      | 4    | 25    |      | 1.49911   |
      | 4    |       | 1910 | 2.28530   |
      | 4    |       |      | 1.61199   |
      |      | 25    | 1910 | 3.14497   |
      |      | 25    |      | 1.81561   |
      |      |       | 1910 | 3.32653   |
      | 4    | 75    | 1983 | 1.39494   |
      | 4    | 75    |      | 1.67734   |
      | 4    |       | 1983 | 1.44683   |
      | 4    |       |      | 1.61199   |
      |      | 75    | 1983 | 1.61067   |
      |      | 75    |      | 2.10777   |
      |      |       | 1983 | 1.68121   |
      | 4    | 500   | 2011 | 2.67899   |
      | 4    | 500   |      | 3.19229   |
      | 4    |       | 2011 | 1.12522   |
      | 4    |       |      | 1.61199   |
      |      | 500   | 2011 | 3.90168   |
      |      | 500   |      | 4.59119   |
      |      |       | 2011 | 1.05013   |

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
