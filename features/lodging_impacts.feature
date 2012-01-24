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
      | GB      |       | 113.98 | defaults |
      | VI      |       | 268.20 | country fuel intens |
      | US      |       | 105.20 | country fuel intens + country elec ef |
      | GB      | Hotel | 113.98 | defaults |
      | VI      | Hotel | 301.20 | country class fuel intens |
      | US      | Hotel | 171.52 | country class fuel intens + country elec ef |
      | US      | Motel |  87.07 | country class fuel intens + country elec ef |
      | US      | Inn   |  87.07 | country class fuel intens + country elec ef |

  Scenario Outline: Calculations involving cohorts
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "state.postal_abbreviation" of "<state>"
    And it has "lodging_class.name" of "<class>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | state | class | carbon | notes |
      | CA    |       |  97.06 | cohort intens div 9 + country elec ef |
      | CA    | Hotel | 166.25 | cohort intens div 9 hotel + country elec ef |
      | CA    | Motel | 112.90 | cohort intens reg 4 + country elec ef |

  Scenario Outline: Calculations with fuel use equations not using climate zone
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "property_rooms" of "<rooms>"
    And it has "property_construction_year" of "<year>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | rooms | year | carbon | notes |
      |  25   | 1910 |  14.92 | rm yr equation |
      |  25   |      |  22.58 | rm equation |
      |       | 1910 |  16.65 | yr equation |
      |  75   | 1983 |  13.77 | rm yr equation |
      |  75   |      |  25.30 | rm equation |
      |       | 1983 |  15.92 | yr equation |
      | 500   | 2011 |  37.50 | rm yr equation |
      | 500   |      |  58.00 | rm equation |
      |       | 2011 |  16.66 | yr equation |
      |       |      | 113.98 | fallbacks |

  Scenario Outline: Calculations with fuel use equations including climate zone
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "zip_code.name" of "<zip>"
    And it has "property_rooms" of "<rooms>"
    And it has "property_construction_year" of "<year>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | zip   | rooms | year | carbon | notes |
      | 94122 |  25   | 1910 | 11.25  | zone rm yr equation + egrid elec ef |
      | 94122 |  25   |      | 10.19  | zone rm equation + egrid elec ef |
      | 94122 |       | 1910 | 13.60  | zone yr equation + egrid elec ef |
      | 94122 |  75   | 1983 | 14.97  | zone rm yr equation + egrid elec ef |
      | 94122 |  75   |      | 11.69  | zone rm equation + egrid elec ef |
      | 94122 |       | 1983 | 19.33  | zone yr equation + egrid elec ef |
      | 94122 | 500   | 2011 | 57.17  | zone rm yr equation + egrid elec ef |
      | 94122 | 500   |      | 35.28  | zone rm equation + egrid elec ef |
      | 94122 |       | 2011 | 23.15  | zone yr equation + egrid elec ef |
      | 94122 |       |      | 12.04  | zone equation + egrid elec ef |

  Scenario Outline: Calculations involving a property
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "lodging_property_name" of "<name>"
    And it has "zip_code.name" of "<zip>"
    And it has "city" of "<city>"
    And it has "state.postal_abbreviation" of "<state>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | name                  | zip   | city          | state | carbon | notes |
      | Hilton San Francisco  |       | San Francisco | CA    | 11.69  | rm yr equation + country elec ef |
      | Hilton San Francisco  | 94122 |               |       | 14.45  | zone rm yr equation + egrid elec ef |
      | Courtyard by Marriott |       | San Francisco | CA    | 13.59  | rm yr equation + country elec ef |
      | Courtyard by Marriott | 94122 | San Francisco | CA    | 17.34  | zone rm yr equation + egrid elec ef |
      | Pacific Inn           |       | San Francisco | CA    | 97.06  | cohort intens div 9 + country elec ef |
      | Pacific Inn           | 94122 | San Francisco | CA    | 12.04  | cohort intens div 9 + country elec ef |
