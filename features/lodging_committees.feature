Feature: Lodging Committee Calculations
  The lodging model should generate correct committee calculations

  Background:
    Given a Lodging

  Scenario: Date committee
    Given a characteristic "timeframe" of "2009-06-06/2010-01-01"
    When the "date" committee reports
    Then the committee should have used quorum "from timeframe"
    And the conclusion of the committee should be "2009-06-06"
    And the conclusion should comply with standards "ghg_protocol_scope_3, iso"

  Scenario: Rooms committee
    When the "rooms" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1.0"

  Scenario: Duration committee
    When the "duration" committee reports
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "86400"

  Scenario: Room nights committee from default
    Given a characteristic "timeframe" of "2009-01-01/2009-02-01"
    When the "date" committee reports
    And the "rooms" committee reports
    And the "duration" committee reports
    And the "room_nights" committee reports
    Then the committee should have used quorum "from rooms, duration, date, and timeframe"
    And the conclusion of the committee should be "1"

  Scenario Outline: Room nights committee
    Given a characteristic "timeframe" of "<timeframe>"
    And characteristic "date" of "<date>"
    And a characteristic "rooms" of "<rooms>"
    And a characteristic "duration" of "<duration>"
    When the "room_nights" committee reports
    Then the committee should have used quorum "from rooms, duration, date, and timeframe"
    And the conclusion of the committee should be "<room_nights>"
    Examples:
      | timeframe             | date       | rooms | duration | room_nights |
      | 2009-01-01/2009-02-01 | 2009-01-15 | 2     | 172800   | 4           |
      | 2009-01-01/2009-02-01 | 2009-02-15 | 2     | 172800   | 0           |

  Scenario: Climate division
    Given a characteristic "zip_code.name" of "94122"
    When the "climate_division" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "name" of "CA4"

  Scenario: City committee
    Given a characteristic "zip_code.name" of "94122"
    When the "city" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should be "San Francisco"

  Scenario: State committee
    Given a characteristic "zip_code.name" of "94122"
    When the "state" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "postal_abbreviation" of "CA"

  Scenario: Egrid subregion committee
    Given a characteristic "zip_code.name" of "94122"
    When the "egrid_subregion" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "abbreviation" of "CAMX"

  Scenario: Country committee
    Given a characteristic "state.postal_abbreviation" of "CA"
    When the "country" committee reports
    Then the committee should have used quorum "from state"
    And the conclusion of the committee should have "iso_3166_code" of "US"

  Scenario Outline: Cooling degree days committee
    Given a characteristic "country.iso_3166_code" of "<country>"
    And a characteristic "climate_division.name" of "<climate_div>"
    When the "cooling_degree_days" committee reports
    Then the committee should have used quorum "<quorum>"
    And the conclusion of the committee should be "<cdd>"
    Examples:
      | country | climate_div | cdd | quorum                |
      | US      |             | 880 | from country          |
      | US      | CA4         | 150 | from climate division |

  Scenario Outline: Heating degree days committee
    Given a characteristic "country.iso_3166_code" of "<country>"
    And a characteristic "climate_division.name" of "<climate_div>"
    When the "heating_degree_days" committee reports
    Then the committee should have used quorum "<quorum>"
    And the conclusion of the committee should be "<hdd>"
    Examples:
      | country | climate_div | hdd  | quorum                |
      | US      |             | 2200 | from country          |
      | US      | CA4         | 1350 | from climate division |

  Scenario Outline: Electricity mix committee
    Given a characteristic "zip_code.name" of "<zip>"
    And a characteristic "state.postal_abbreviation" of "<state>"
    And a characteristic "country.iso_3166_code" of "<country>"
    When the "state" committee reports
    And the "egrid_subregion" committee reports
    And the "electricity_mix" committee reports
    Then the committee should have used quorum "<quorum>"
    And the conclusion of the committee should have "name" of "<mix>"
    Examples:
      | zip   | state | country | mix                              | quorum               |
      | 94122 |       |         | CAMX egrid subregion electricity | from egrid subregion |
      | 94133 |       |         | CA state electricity             | from state           |
      |       | CA    |         | CA state electricity             | from state           |
      |       |       | US      | US national electricity          | from country         |
      |       |       |         | fallback                         | default              |

  Scenario: Floors committee
    Given a characteristic "property.northstar_id" of "1"
    When the "floors" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "3"

  Scenario: Construction year committee
    Given a characteristic "property.northstar_id" of "1"
    When the "construction_year" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "1993"

  Scenario: AC coverage committee
    Given a characteristic "property.northstar_id" of "1"
    When the "ac_coverage" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "0.5"

  Scenario Outline: Refrigerator coverage committee
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

  Scenario Outline: Hot tubs committee
    Given a characteristic "property.hot_tubs" of "<tubs>"
    When the "hot_tubs" committee reports
    Then the committee should have used quorum "from property"
    And the conclusion of the committee should be "<count>"
    Examples:
      | tubs | count |
      |    0 |     0 |
      |    1 |     1 |
      |    6 |     6 |

  Scenario Outline: Indoor pools committee
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

  Scenario Outline: Outdoor pools committee
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

  Scenario Outline: Occupancy rate committee
    Given a characteristic "country.iso_3166_code" of "<country>"
    When the "occupancy_rate" committee reports
    Then the committee should have used quorum "<quorum>"
    And the conclusion of the committee should be "<rate>"
    Examples:
      | country | quorum       | rate |
      | US      | from country | 0.6  |
      | GB      | from country | 0.5  |
      |         | default      | 0.6  |

  Scenario Outline: Fuel intensities committee
    Given a characteristic "heating_degree_days" of "<hdd>"
    And a characteristic "cooling_degree_days" of "<cdd>"
    And a characteristic "property_rooms" of "<rooms>"
    And a characteristic "floors" of "<floors>"
    And a characteristic "construction_year" of "<year>"
    And a characteristic "ac_coverage" of "<ac>"
    When the "occupancy_rate" committee reports
    And the "fuel_intensities" committee reports
    Then the committee should have used quorum "<quorum>"
    And the conclusion of the committee should include a key of "natural_gas" and value "<gas>"
    And the conclusion of the committee should include a key of "fuel_oil" and value "<oil>"
    And the conclusion of the committee should include a key of "electricity" and value "<elec>"
    And the conclusion of the committee should include a key of "district_heat" and value "<steam>"
    Examples:
     | hdd  | cdd  | rooms | floors | year | ac  | gas       | oil      | elec      | steam   | notes          | quorum                                            |
     |      |      |       |        |      |     | 103.33333 | 38.16667 | 122.00000 | 1.66667 | default        | default                                           |
     | 1350 |      |       |        |      |     | 103.33333 | 38.16667 | 122.00000 | 1.66667 | default        | default                                           |
     |      |  150 |       |        |      |     | 103.33333 | 38.16667 | 122.00000 | 1.66667 | default        | default                                           |
     | 1350 |  150 |       |        |      |     | 107.24246 | 36.83606 | 121.36750 | 2.27633 | CA hdd/cdd     | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 | 100   |        |      |     | 118.84683 | 35.40246 | 129.75680 | 3.24431 | CA hdd/cdd     | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 |       |   3    |      |     | 103.87696 | 35.69752 | 118.05079 | 2.44277 | CA hdd/cdd     | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 |       |        | 1993 |     | 136.66597 | 43.09050 | 158.91655 | 3.72728 | CA hdd/cdd     | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 |       |        |      | 0.5 | 129.09992 | 35.80292 | 164.86359 | 3.98241 | CA hdd/cdd     | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 | 100   |   3    | 1993 | 0.5 | 152.12258 | 36.35656 | 192.41523 | 5.69299 | CA hdd/cdd     | from degree days, occupancy rate, and user inputs |
     | 9999 |    0 |       |        |      |     |  43.30826 | 51.51780 |  88.96808 | 0.29828 | extreme hdd    | from degree days, occupancy rate, and user inputs |
     | 2200 |  880 |       |        |      |     | 102.90627 | 34.52418 | 115.03006 | 0.06874 | us hdd/cdd     | from degree days, occupancy rate, and user inputs |
     | 2200 |  880 | 25    |        |      |     |  91.68020 | 34.88689 | 103.77213 | 0.04637 |                | from degree days, occupancy rate, and user inputs |
     |    0 | 4000 |       |        |      |     | 147.56487 | 28.66915 | 138.84885 | 3.39636 | extreme cdd    | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 | 1     |        |      |     |  90.75820 | 38.62994 | 106.20389 | 1.50399 | extreme rooms  | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 | 5000  |        |      |     | 122.53465 | 35.63871 | 135.84374 | 2.48866 | extreme rooms  | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 |       |   1    |      |     |  98.84393 | 40.70539 | 107.87025 | 1.73642 | extreme floors | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 |       | 100    |      |     | 123.35874 | 34.51253 | 139.05201 | 2.42997 | extreme floors | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 |       |        | 1200 |     |  87.26936 | 31.10031 | 105.46260 | 1.62396 | extreme year   | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 |       |        | 2012 |     | 143.57433 | 40.79883 | 168.06963 | 4.51155 | extreme year   | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 |       |        |      | 0.0 |  31.64684 |  9.49518 |  81.09034 | 0.86445 | extreme ac     | from degree days, occupancy rate, and user inputs |
     | 1350 |  150 |       |        |      | 1.0 | 119.79486 | 44.22917 | 121.01386 | 2.12704 | extreme ac     | from degree days, occupancy rate, and user inputs |

 Scenario Outline: Refrigerator adjustment committee
   Given a characteristic "refrigerator_coverage" of "<coverage>"
   And a characteristic "occupancy_rate" of "0.6"
   And the "refrigerator_adjustment" committee reports
   Then the committee should have used quorum "from refrigerator coverage and occupancy rate"
   And the conclusion of the committee should include a key of "electricity" and value "<adjustment>"
   Examples:
     | coverage | adjustment |
     |        0 |   -4.248   |
     |        1 |    2.832   |

  Scenario Outline: Hot tub adjustment committee
    Given a characteristic "hot_tubs" of "<hot_tubs>"
    And a characteristic "property_rooms" of "25"
    And a characteristic "occupancy_rate" of "0.6"
    When the "hot_tub_adjustment" committee reports
    Then the committee should have used quorum "from hot tubs, property rooms, and occupancy rate"
    And the conclusion of the committee should include a key of "electricity" and value "<adjustment>"
    Examples:
      | hot_tubs | adjustment |
      |        0 |    -0.4536 |
      |        1 |     1.0584 |

  Scenario Outline: Indoor pool adjustment committee
    Given a characteristic "indoor_pools" of "<pools>"
    And a characteristic "property_rooms" of "25"
    And a characteristic "occupancy_rate" of "0.6"
    When the "indoor_pool_adjustment" committee reports
    Then the committee should have used quorum "from indoor pools, property rooms, and occupancy rate"
    And the conclusion of the committee should include a key of "pool_energy" and value "<adjustment>"
    Examples:
      | pools | adjustment |
      |     0 |  -58.46997 |
      |     1 |  136.42993 |
      |     5 |  916.02955 |

  Scenario Outline: Outdoor pool adjustment committee
    Given a characteristic "outdoor_pools" of "<pools>"
    And a characteristic "property_rooms" of "25"
    And a characteristic "occupancy_rate" of "0.6"
    When the "outdoor_pool_adjustment" committee reports
    Then the committee should have used quorum "from outdoor pools, property rooms, and occupancy rate"
    And the conclusion of the committee should include a key of "pool_energy" and value "<adjustment>"
    Examples:
      | pools | adjustment |
      |     0 |  -13.92323 |
      |     1 |    9.28216 |
      |     5 |  102.10372 |

  Scenario Outline: Adjusted fuel intensities committee
    Given a characteristic "heating_degree_days" of "2200"
    And a characteristic "cooling_degree_days" of "880"
    And a characteristic "property_rooms" of "25"
    And a characteristic "occupancy_rate" of "0.6"
    And a characteristic "refrigerator_coverage" of "<rc>"
    And a characteristic "hot_tubs" of "<tubs>"
    And a characteristic "indoor_pools" of "<ip>"
    And a characteristic "outdoor_pools" of "<op>"
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
     | rc | tubs | ip | op | gas       | oil      | elec      | steam   |
     |    |      |    |    |  91.68020 | 34.88689 | 103.77213 | 0.04637 |
     |  0 |      |    |    |  91.68020 | 34.88689 |  99.52413 | 0.04637 |
     |  1 |      |    |    |  91.68020 | 34.88689 | 106.60413 | 0.04637 |
     |    |    0 |    |    |  91.68020 | 34.88689 | 103.31853 | 0.04637 |
     |    |    1 |    |    |  91.68020 | 34.88689 | 104.83053 | 0.04637 |
     |    |      |  0 |    |  33.21023 | 34.88689 | 103.77213 | 0.04637 |
     |    |      |  1 |    | 228.11013 | 34.88689 | 103.77213 | 0.04637 |
     |    |      |    |  0 |  77.75696 | 34.88689 | 103.77213 | 0.04637 |
     |    |      |    |  1 | 100.96235 | 34.88689 | 103.77213 | 0.04637 |
     |  0 |    0 |  0 |  0 |  19.28699 | 34.88689 |  99.07053 | 0.04637 |
     |  1 |    1 |  1 |  1 | 237.39229 | 34.88689 | 107.66253 | 0.04637 |

  Scenario: Fuel uses committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "adjusted_fuel_intensities" committee reports
    And the "fuel_uses" committee reports
    Then the committee should have used quorum "from adjusted fuel intensities and room nights"
    And the conclusion of the committee should include a key of "natural_gas" and value "413.33333"
    And the conclusion of the committee should include a key of "fuel_oil" and value "152.66667"
    And the conclusion of the committee should include a key of "electricity" and value "488.00000"
    And the conclusion of the committee should include a key of "district_heat" and value "6.66667"

  Scenario: Energy committee
    Given a characteristic "room_nights" of "4"
    When the "fuel_intensities" committee reports
    And the "adjusted_fuel_intensities" committee reports
    And the "fuel_uses" committee reports
    And the "energy" committee reports
    Then the committee should have used quorum "from fuel uses"
    And the conclusion of the committee should be "1060.66667"

  Scenario: N2O emission committee
    Given a characteristic "room_nights" of "4"
    When the "electricity_mix" committee reports
    And the "fuel_intensities" committee reports
    And the "adjusted_fuel_intensities" committee reports
    And the "fuel_uses" committee reports
    And the "energy" committee reports
    When the "n2o_emission" committee reports
    Then the conclusion of the committee should be "0.35611"

  Scenario: CH4 emission committee
    Given a characteristic "room_nights" of "4"
    When the "electricity_mix" committee reports
    And the "fuel_intensities" committee reports
    And the "adjusted_fuel_intensities" committee reports
    And the "fuel_uses" committee reports
    And the "energy" committee reports
    When the "ch4_emission" committee reports
    Then the conclusion of the committee should be "0.03141"

  Scenario: CO2 emission committee
    Given a characteristic "room_nights" of "4"
    When the "electricity_mix" committee reports
    And the "fuel_intensities" committee reports
    And the "adjusted_fuel_intensities" committee reports
    And the "fuel_uses" committee reports
    And the "energy" committee reports
    When the "co2_emission" committee reports
    Then the conclusion of the committee should be "116.41040"
