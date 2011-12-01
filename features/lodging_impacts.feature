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
      | location          | zip   | state | country | carbon |
      | London, UK        |       |       | GB      | 168.12 |
      | USA               |       |       | US      | 168.12 |
      | San Francisco, CA |       | CA    | US      |  85.69 |
      | 94122             | 94122 | CA    | US      |  50.72 |

  Scenario Outline: Calculations from rooms, duration, and country lodging class
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "lodging_class.name" of "Hotel"
    And it has "location_description" of "location"
    And the geocoder will encode the location_description as "" with zip code "<zip>", state "<state>", and country "<country>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | location          | zip   | state | country | carbon |
      | London, UK        |       |       | GB      | 168.12 |
      | USA               |       |       | US      | 168.12 |
      | San Francisco, CA |       | CA    | US      |  85.69 |
      | 94122             | 94122 | CA    | US      |  50.72 |
