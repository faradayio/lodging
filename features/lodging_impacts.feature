Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Background:
    Given a Lodging

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "28.49"

  Scenario Outline: Calculations starting from date
    Given it has "date" of "<date>"
    And it has "timeframe" of "<timeframe>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | date       | timeframe             | carbon |
      | 2011-01-15 | 2011-01-01/2012-01-01 | 28.49  |
      | 2012-01-15 | 2011-01-01/2012-01-01 |  0.0   |

  Scenario: Calculations starting from rooms and duration
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "113.98"

  Scenario Outline: Calculations from rooms, duration, country, and lodging class
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "country.iso_3166_code" of "<country>"
    And it has "lodging_class.name" of "<class>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | country | class | carbon | notes |
      | VI      |       | 113.98 | country missing fuel intensities and elec ef |
      | GB      |       | 268.20 | country with fuel intensities but no elec ef |
      | US      |       | 105.20 | country with intensities + elec ef |
      | VI      | Hotel | 113.98 | country missing fuel intensities and elec ef |
      | GB      | Hotel | 301.20 | country with fuel intensities but no elec ef |
      | US      | Hotel | 171.52 | country with intensities + elec ef |
      | US      | Motel |  87.07 | country with intensities + elec ef |
      | US      | Inn   |  87.07 | country with intensities + elec ef |

  Scenario Outline: Calculations from rooms, duration, zip, state, lodging class, and property rooms
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "zip_code.name" of "<zip>"
    And it has "state.postal_abbreviation" of "<state>"
    And it has "lodging_class.name" of "<class>"
    And it has "property_rooms" of "<property_rooms>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | zip      | state | class | property_rooms | carbon | notes |
      |          | CA    |       |                |  90.42 | cohort from division; elec ef from country |
      |          | CA    | Hotel | 50             |  93.81 | cohort from class, rooms, division; elec ef from country |
      | 94122    |       |       |                |  55.36 | cohort from division; elec ef from egrid |
      | 94122    |       | Hotel | 50             |  58.00 | cohort from class, rooms, division; elec ef from egrid |
      |          | CA    |       | 20             |  79.50 | cohort from rooms, region; elec ef from country |

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
      | 2  | Courtyard by Marriott |       | San Francisco | CA    | 87.03  | cohort based on class only; elec ef from country |
      | 1  | Hilton San Francisco  |       | San Francisco | CA    | 93.81  | cohort based on class rooms division; elec ef from country |
      | 1  | Hilton San Francisco  | 94122 |               |       | 58.00  | cohort based on class rooms division; elec ef from egrid |
      |    | Pacific Inn           |       | San Francisco | CA    | 90.42  | not enough to identify property; cohort from division; elec ef from country |
