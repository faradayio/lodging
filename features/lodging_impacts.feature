Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Background:
    Given a Lodging

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "28.49"

  Scenario: Calculations starting from rooms and duration
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "113.98"

  Scenario Outline: Calculations from rooms, duration, postcode, locality, and country
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "postcode" of "<postcode>"
    And it has "locality" of "<locality>"
    And it has "country.iso_3166_code" of "<country>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | postcode | locality   | country | carbon | notes |
      |          |            | GB      | 113.98 | country missing fuel intensities and elec ef |
      |          |            | VI      | 268.20 | country with fuel intensities but no elec ef |
      |          |            | US      | 105.20 | country with intensities + elec ef |
      |          | California |         |  90.42 | cohort census division |
      | 94122    |            |         |  55.36 | cohort census division + egrid |

  Scenario Outline: Calculations from rooms, duration, postcode, locality, and country
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "lodging_class.name" of "<class>"
    And it has "property_rooms" of "<property_rooms>"
    And it has "postcode" of "<postcode>"
    And it has "locality" of "<locality>"
    And it has "country.iso_3166_code" of "<country>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | class | property_rooms | postcode | locality   | country | carbon | notes |
      | Hotel |                |          |            | GB      | 113.98 | county only |
      | Hotel |                |          |            | VI      | 301.20 | country lodging class |
      | Inn   |                |          |            | US      |  87.03 | cohort country lodging class |
      | Hotel | 50             |          | California |         |  93.81 | cohort country lodging class rooms division |
      | Hotel | 50             | 94122    |            |         |  58.00 | cohort country lodging class rooms division + egrid |
      |       | 20             |          | California |         |  79.50 | cohort rooms region + egrid |
