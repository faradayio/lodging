Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Background:
    Given a Lodging

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When impacts are calculated
    Then the amount of "carbon" should be within "0.005" of "29.20"
    And the amount of "energy" should be within "0.005" of "265.17"

  Scenario Outline: Calculations starting from date
    Given it has "date" of "<date>"
    And it has "timeframe" of "<timeframe>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.005" of "<carbon>"
    Examples:
      | date       | timeframe             | carbon | energy |
      | 2011-01-15 | 2011-01-01/2012-01-01 |  29.20 | 265.17 |
      | 2012-01-15 | 2011-01-01/2012-01-01 |   0.0  |   0.0  |

  Scenario: Calculations starting from rooms and duration
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.005" of "116.80"
    And the amount of "energy" should be within "0.005" of "1060.67"

  Scenario Outline: Calculations from fuzzy inference based on country degree days
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "country.iso_3166_code" of "<country>"
    And it has "state.postal_abbreviation" of "<state>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.005" of "<carbon>"
    And the amount of "energy" should be within "0.005" of "<energy>"
    Examples:
      | country | state | carbon | energy  |
      | VI      |       | 116.80 | 1060.67 |
      | GB      |       | 115.91 |  984.23 |
      | US      |       | 100.97 | 1010.12 |
      |         | CA    |  68.82 | 1010.12 |

  Scenario Outline: Calculations from fuzzy inference
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "property.northstar_id" of "<id>"
    And it has "zip_code.name" of "<zip>"
    And it has "city" of "<city>"
    And it has "state.postal_abbreviation" of "<state>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.005" of "<carbon>"
    And the amount of "energy" should be within "0.005" of "<energy>"
    Examples:
      | id | zip   | city          | state | carbon | energy  | notes |
      | 1  | 94122 |               |       | 158.46 | 2573.10 | dd from climate divizion; fuzzy from property attributes |
      | 1  |       | San Francisco | CA    | 159.31 | 2487.19 | dd from country; fuzzy from property attributes |
      | 2  | 94133 |               |       |  61.28 |  842.64 | dd from country; fuzzy from property attributes |
      | 2  |       | San Francisco | CA    |  61.28 |  842.64 | dd from country; fuzzy from property attributes |
      | 3  | 94014 |               |       |  92.17 | 1505.79 | dd from country; fuzzy from property attributes |

  Scenario: Calculations from all user inputs
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "country.iso_3166_code" of "GB"
    And it has "heating_degree_days" of "2700"
    And it has "cooling_degree_days" of "100"
    And it has "property_rooms" of "100"
    And it has "floors" of "3"
    And it has "construction_year" of "1993"
    And it has "ac_coverage" of "0.5"
    And it has "refrigerator_coverage" of "0.6"
    And it has "hot_tubs" of "6"
    And it has "indoor_pools" of "5"
    And it has "outdoor_pools" of "5"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.005" of "316.07"
    And the amount of "energy" should be within "0.005" of "3146.24"
