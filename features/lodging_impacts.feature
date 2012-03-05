Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Background:
    Given a Lodging

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "28.62"

  Scenario Outline: Calculations starting from date
    Given it has "date" of "<date>"
    And it has "timeframe" of "<timeframe>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | date       | timeframe             | carbon |
      | 2011-01-15 | 2011-01-01/2012-01-01 |  28.62 |
      | 2012-01-15 | 2011-01-01/2012-01-01 |   0.0  |

  Scenario: Calculations starting from rooms and duration
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "114.46"

  Scenario Outline: Calculations from fuzzy inference based on country degree days
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "country.iso_3166_code" of "<country>"
    And it has "state.postal_abbreviation" of "<state>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | country | state | carbon |
      | VI      |       | 114.46 |
      | GB      |       | 189.56 |
      | US      |       | 131.28 |
      |         | CA    | 131.28 |

  Scenario Outline: Calculations from fuzzy inference
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "property.northstar_id" of "<id>"
    And it has "zip_code.name" of "<zip>"
    And it has "city" of "<city>"
    And it has "state.postal_abbreviation" of "<state>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | id | zip   | city          | state | carbon | notes |
      | 1  | 94122 |               |       |  86.85 | dd from climate divizion; fuzzy from property attributes |
      | 1  |       | San Francisco | CA    | 122.33 | dd from country; fuzzy from property attributes |
      | 2  | 94133 |               |       |  94.24 | dd from country; fuzzy from property attributes |
      | 2  |       | San Francisco | CA    |  94.24 | dd from country; fuzzy from property attributes |
      | 3  | 94014 |               |       | 128.13 | dd from country; fuzzy from property attributes |

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
    Then the amount of "carbon" should be within "0.01" of "208.83"
