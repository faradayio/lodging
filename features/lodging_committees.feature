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

  Scenario: Floors
    Given a characteristic "property.northstar_id" of "1"
    When the "floors" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "3"

  Scenario: Construction year
    Given a characteristic "property.northstar_id" of "1"
    When the "construction_year" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "1993"

  Scenario: AC coverage
    Given a characteristic "property.northstar_id" of "1"
    When the "ac_coverage" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "0.5"

  Scenario Outline: Refrigerator coverage
    Given a characteristic "property.northstar_id" of "<id>"
    When the "refrigerator_coverage" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "<coverage>"
    Examples:
      | id | coverage |
      | 1  | 0.6      |
      | 2  | 0.5      |
      | 3  | 0.5      |
      | 4  | 0.6      |

  Scenario Outline: Hot tubs
    Given a characteristic "property.hot_tubs" of "<tubs>"
    When the "hot_tubs" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "<count>"
    Examples:
      | tubs | count |
      |    0 |     0 |
      |    1 |     1 |
      |    6 |     6 |

  Scenario Outline: Indoor pools
    Given a characteristic "property.pools_indoor" of "<pools>"
    When the "indoor_pools" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "<count>"
    Examples:
      | pools | count |
      |     0 |     0 |
      |     1 |     1 |
      |     5 |     5 |
      |     6 |     5 |

  Scenario Outline: Outdoor pools
    Given a characteristic "property.pools_outdoor" of "<pools>"
    When the "outdoor_pools" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "<count>"
    Examples:
      | pools | count |
      |     0 |     0 |
      |     1 |     1 |
      |     5 |     5 |
      |     6 |     5 |

  Scenario Outline: Occupancy rate
    Given a characteristic "country.iso_3166_code" of "<country>"
    When the "occupancy_rate" committee reports
    Then the committee should have used quorum "<quorum>"
    And the conclusion of the committee should be "<rate>"
    Examples:
      | country | quorum       | rate |
      | US      | from country | 0.6  |
      | GB      | from country | 0.5  |
      |         | default      | 0.6  |

  Scenario: Fuel intensities committee from default
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should include a key of "natural_gas" and value "2.0"
    And the conclusion of the committee should include a key of "fuel_oil" and value "0.4"
    And the conclusion of the committee should include a key of "electricity" and value "33.9"
    And the conclusion of the committee should include a key of "district_heat" and value "1.8"

  Scenario Outline: Fuel intensities committee should not run unless both hdd and cdd are present
    Given a characteristic "<dd_characteristic>" of "500"
    And a characteristic "occupancy_rate" of "0.6"
    When the "fuel_intensities" committee reports
    Then the committee should have used quorum "default"
    Examples:
     | dd_characteristic   |
     | heating_degree_days |
     | cooling_degree_days |

  Scenario Outline: Fuel intensities committee from fuzzy weighting
    Given a characteristic "heating_degree_days" of "<hdd>"
    And a characteristic "cooling_degree_days" of "<cdd>"
    And a characteristic "property_rooms" of "<rooms>"
    And a characteristic "floors" of "<floors>"
    And a characteristic "construction_year" of "<year>"
    And a characteristic "ac_coverage" of "<ac>"
    When the "occupancy_rate" committee reports
    And the "fuel_intensities" committee reports
    Then the committee should have used quorum "from degree days, occupancy rate, and user inputs"
    And the conclusion of the committee should include a key of "natural_gas" and value "<gas>"
    And the conclusion of the committee should include a key of "fuel_oil" and value "<oil>"
    And the conclusion of the committee should include a key of "electricity" and value "<elec>"
    And the conclusion of the committee should include a key of "district_heat" and value "<steam>"
    Examples:
     | hdd   | cdd  | rooms | floors | year | ac  | gas     | oil     | elec     | steam    | notes |
     |  1350 |  150 |       |        |      |     | 1.10187 | 2.90728 | 31.32292 | 14.80000 | CA hdd/cdd |
     |  1350 |  150 | 100   |        |      |     | 0.85612 | 2.96930 | 28.21736 | 13.57824 | CA hdd/cdd |
     |  1350 |  150 |       |   3    |      |     | 0.83468 | 3.04853 | 27.88175 | 13.76680 | CA hdd/cdd |
     |  1350 |  150 |       |        | 1993 |     | 1.23045 | 0.77795 | 40.53607 |  4.15725 | CA hdd/cdd |
     |  1350 |  150 |       |        |      | 0.5 | 0.42758 | 1.12817 | 26.43368 |  5.74312 | CA hdd/cdd |
     |  1350 |  150 | 100   |   3    | 1993 | 0.5 | 0.08723 | 0.13344 | 25.02442 |  0.76500 | CA hdd/cdd |
     | 10000 |    0 |       |        |      |     | 0.23482 | 3.52029 | 22.33470 |  1.98967 | extreme hdd |
     |  2200 |  880 |       |        |      |     | 0.96884 | 0.82078 | 44.47599 |  7.70066 | us hdd/cdd |
     |  2200 |  880 | 25    |        |      |     | 0.01922 | 0.91159 | 34.86144 |  0.37174 | |
     |     0 | 4000 |       |        |      |     | 4.33735 | 0.65661 | 60.84568 | 63.33742 | extreme cdd |
     |  1350 |  150 | 1     |        |      |     | 0.77635 | 3.02573 | 27.72495 | 13.32596 | extreme rooms |
     |  1350 |  150 | 5000  |        |      |     | 1.82944 | 2.74889 | 38.73677 | 15.59486 | extreme rooms |
     |  1350 |  150 |       |   1    |      |     | 0.82413 | 3.14038 | 28.48186 | 13.77581 | extreme floors |
     |  1350 |  150 |       | 100    |      |     | 1.97743 | 2.57705 | 40.83635 | 19.22833 | extreme floors |
     |  1350 |  150 |       |        | 1200 |     | 0.86163 | 3.04800 | 27.19855 | 13.25471 | extreme year |
     |  1350 |  150 |       |        | 2012 |     | 1.25202 | 0.65488 | 41.13082 |  4.08640 | extreme year |
     |  1350 |  150 |       |        |      | 0.0 | 0.06504 | 4.59438 | 17.82449 |  0.87348 | extreme ac |
     |  1350 |  150 |       |        |      | 1.0 | 2.32907 | 1.29925 | 46.77370 | 31.28316 | extreme ac |

 Scenario Outline: Refrigerator adjustment
   Given a characteristic "refrigerator_coverage" of "<coverage>"
   And a characteristic "occupancy_rate" of "0.6"
   And the "refrigerator_adjustment" committee reports
   Then the committee should have used quorum "from refrigerator coverage and occupancy rate"
   And the conclusion of the committee should include a key of "electricity" and value "<adjustment>"
   Examples:
     | coverage | adjustment |
     |        0 |   -1.18    |
     |        1 |    0.78667 |

  Scenario Outline: Hot tub adjustment
    Given a characteristic "hot_tubs" of "<hot_tubs>"
    And a characteristic "property_rooms" of "10"
    And a characteristic "occupancy_rate" of "0.6"
    When the "hot_tub_adjustment" committee reports
    Then the committee should have used quorum "from hot tubs, property rooms, and occupancy rate"
    And the conclusion of the committee should include a key of "electricity" and value "<adjustment>"
    Examples:
      | hot_tubs | adjustment |
      |        0 |     -0.315 |
      |        1 |      0.735 |

  Scenario Outline: Indoor pool adjustment
    Given a characteristic "indoor_pools" of "<pools>"
    And a characteristic "property_rooms" of "10"
    And a characteristic "occupancy_rate" of "0.6"
    When the "indoor_pool_adjustment" committee reports
    Then the committee should have used quorum "from indoor pools, property rooms, and occupancy rate"
    And the conclusion of the committee should include a key of "pool_energy" and value "<adjustment>"
    Examples:
      | pools | adjustment |
      |     0 | -146.17493 |
      |     1 |  341.07483 |
      |     5 | 2290.07388 |

  Scenario Outline: Outdoor pool adjustment
    Given a characteristic "outdoor_pools" of "<pools>"
    And a characteristic "property_rooms" of "10"
    And a characteristic "occupancy_rate" of "0.6"
    When the "outdoor_pool_adjustment" committee reports
    Then the committee should have used quorum "from outdoor pools, property rooms, and occupancy rate"
    And the conclusion of the committee should include a key of "pool_energy" and value "<adjustment>"
    Examples:
      | pools | adjustment |
      |     0 |  -34.80809 |
      |     1 |   23.20539 |
      |     5 |  255.25930 |

  Scenario Outline: Adjusted fuel intensities committee from fuel intensities, pool adjustment, and refrigerator adjustment
    Given a characteristic "heating_degree_days" of "2200"
    And a characteristic "cooling_degree_days" of "880"
    And a characteristic "property_rooms" of "25"
    And a characteristic "occupancy_rate" of "0.6"
    And a characteristic "refrigerator_coverage" of "<refrigerators>"
    And a characteristic "hot_tubs" of "<tubs>"
    And a characteristic "indoor_pools" of "<indoor_pools>"
    And a characteristic "outdoor_pools" of "<outdoor_pools>"
    When the "fuel_intensities" committee reports
    And the "refrigerator_adjustment" committee reports
    And the "hot_tub_adjustment" committee reports
    And the "indoor_pool_adjustment" committee reports
    And the "outdoor_pool_adjustment" committee reports
    And the "adjusted_fuel_intensities" committee reports
    Then the committee should have used quorum "from fuel intensities and amenity adjustments"
    And the conclusion of the committee should include a key of "natural_gas" and value "<gas>"
    And the conclusion of the committee should include a key of "fuel_oil" and value "<oil>"
    And the conclusion of the committee should include a key of "electricity" and value "<elec>"
    And the conclusion of the committee should include a key of "district_heat" and value "<steam>"
    Examples:
     | refrigerators | tubs | indoor_pools | outdoor_pools | gas     | oil     | elec     | steam   |
     |               |      |              |               | 0.01922 | 0.91159 | 34.86144 | 0.37174 |
     |            0  |      |              |               | 0.01922 | 0.91159 | 33.68144 | 0.37174 |
     |            1  |      |              |               | 0.01922 | 0.91159 | 35.64811 | 0.37174 |
     |               |    0 |              |               | 0.01922 | 0.91159 | 34.73544 | 0.37174 |
     |               |    1 |              |               | 0.01922 | 0.91159 | 35.15544 | 0.37174 |
     |               |      |            0 |               | 0.0     | 0.0     | 34.86144 | 0.37174 |
     |               |      |            1 |               | 3.60948 | 0.91159 | 34.86144 | 0.37174 |
     |               |      |              |             0 | 0.0     | 0.59747 | 34.86144 | 0.37174 |
     |               |      |              |             1 | 0.26349 | 0.91159 | 34.86144 | 0.37174 |

  Scenario: District heat use committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "adjusted_fuel_intensities" committee reports
    And the "district_heat_use" committee reports
    Then the committee should have used quorum "from adjusted fuel intensities and room nights"
    And the conclusion of the committee should be "7.2"
    
  Scenario: Electricity use committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "adjusted_fuel_intensities" committee reports
    And the "electricity_use" committee reports
    Then the committee should have used quorum "from adjusted fuel intensities and room nights"
    And the conclusion of the committee should be "135.6"
    
  Scenario: Fuel oil use committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "adjusted_fuel_intensities" committee reports
    And the "fuel_oil_use" committee reports
    Then the committee should have used quorum "from adjusted fuel intensities and room nights"
    And the conclusion of the committee should be "1.6"
    
  Scenario: Natural gas use committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "adjusted_fuel_intensities" committee reports
    And the "natural_gas_use" committee reports
    Then the committee should have used quorum "from adjusted fuel intensities and room nights"
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
