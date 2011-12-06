Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Background:
    Given a Lodging

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "42.03"

  Scenario: Calculations starting from rooms and duration
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "168.12"

  Scenario Outline: Calculations from rooms, duration, and location
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "location_description" of "location"
    And the geocoder will encode the location_description as "" with zip code "<zip>", state "<state>", and country "<country>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | location          | zip   | state | country | carbon | notes |
      | London, UK        |       |       | GB      | 168.12 | country missing fuel intensities and elec ef |
      | Virgin Islands    |       |       | VI      | 187.24 | country with fuel intensities but no elec ef |
      | USA               |       |       | US      | 168.12 | country with intensities + elec ef |
      | San Francisco, CA |       | CA    | US      |  85.69 | census division |
      | 94122             | 94122 | CA    | US      |  50.72 | census division + egrid |

  Scenario Outline: Calculations from rooms, duration, location, and lodging class
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "lodging_class.name" of "Hotel"
    And it has "location_description" of "location"
    And the geocoder will encode the location_description as "" with zip code "<zip>", state "<state>", and country "<country>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | location          | zip   | state | country | carbon | notes |
      | London, UK        |       |       | GB      | 168.12 | invalid country lodging class |
      | Virgin Islands    |       |       | VI      | 187.24 | invalid country lodging class |
      | USA               |       |       | US      | 168.12 | country lodging class |
      | San Francisco, CA |       | CA    | US      | 174.70 | census region lodging class |
      | 94122             | 94122 | CA    | US      | 110.78 | census region lodging class + egrid |
