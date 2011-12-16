Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Background:
    Given a Lodging

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "28.55"

  Scenario: Calculations starting from rooms and duration
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "114.19"

  Scenario Outline: Calculations from rooms, duration, and location
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "location_description" of "location"
    And the geocoder will encode the location_description as "" with zip code "<zip>", state "<state>", and country "<country>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | location          | zip   | state | country | carbon | notes |
      | London, UK        |       |       | GB      | 114.19 | country missing fuel intensities and elec ef |
      | Virgin Islands    |       |       | VI      | 268.20 | country with fuel intensities but no elec ef |
      | USA               |       |       | US      | 105.42 | country with intensities + elec ef |
      | San Francisco, CA |       | CA    | US      |  90.42 | cohort census division |
      | 94122             | 94122 | CA    | US      |  55.36 | cohort census division + egrid |

  Scenario Outline: Calculations from rooms, duration, location, and lodging class
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "lodging_class.name" of "<class>"
    And it has "building_rooms" of "<building_rooms>"
    And it has "location_description" of "location"
    And the geocoder will encode the location_description as "" with zip code "<zip>", state "<state>", and country "<country>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | class        | building_rooms | location          | zip   | state | country | carbon | notes |
      | Hotel        |                | London, UK        |       |       | GB      | 114.19 | county only |
      | Hotel        |                | Virgin Islands    |       |       | VI      | 301.20 | country lodging class |
      | Motel or inn |                | USA               |       |       | US      |  87.03 | cohort lodging class |
      | Hotel        | 50             | San Francisco, CA |       | CA    | US      |  93.81 | cohort lodging class rooms division |
      | Hotel        | 50             | 94122             | 94122 | CA    | US      |  58.00 | cohort lodging class rooms division + egrid |
      |              | 20             | San Francisco, CA |       | CA    | US      |  79.50 | cohort rooms region + egrid |
