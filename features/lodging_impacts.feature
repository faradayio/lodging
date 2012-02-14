Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Background:
    Given a Lodging

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "28.50"

  Scenario Outline: Calculations starting from date
    Given it has "date" of "<date>"
    And it has "timeframe" of "<timeframe>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | date       | timeframe             | carbon |
      | 2011-01-15 | 2011-01-01/2012-01-01 |  28.50 |
      | 2012-01-15 | 2011-01-01/2012-01-01 |   0.0  |

  Scenario: Calculations starting from rooms and duration
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "113.98"

  Scenario Outline: Calculations from rooms, duration, country, and lodging class
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "country.iso_3166_code" of "<country>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | country | carbon | notes |
      | VI      | 113.98 | country missing degree days and elec ef |
      | GB      | 113.98 | country with degree days and elec ef |
      | US      | 113.98 | country with degree days and elec ef |
  
  Scenario Outline: Calculations involving a property
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "property.northstar_id" of "<id>"
    And it has "zip_code.name" of "<zip>"
    And it has "city" of "<city>"
    And it has "state.postal_abbreviation" of "<state>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | id | name                  | zip   | city          | state | carbon | notes |
      | 2  | Courtyard by Marriott |       | San Francisco | CA    | 87.03  | |
      | 1  | Hilton San Francisco  |       | San Francisco | CA    | 93.81  | |
      | 1  | Hilton San Francisco  | 94122 |               |       | 58.00  | |
      |    | Pacific Inn           |       | San Francisco | CA    | 90.42  | |
