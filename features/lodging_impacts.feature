Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Background:
    Given a Lodging

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "25.06"

  Scenario Outline: Calculations starting from date
    Given it has "date" of "<date>"
    And it has "timeframe" of "<timeframe>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | date       | timeframe             | carbon |
      | 2011-01-15 | 2011-01-01/2012-01-01 | 25.06  |
      | 2012-01-15 | 2011-01-01/2012-01-01 |  0.0   |

  Scenario: Calculations starting from rooms and duration
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "100.25"

  Scenario Outline: Calculations from rooms, duration, and country
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "country.iso_3166_code" of "<country>"
    And it has "state.postal_abbreviation" of "<state>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | country | state | carbon | notes |
      | GB      |       | 100.25 | defaults |
      | VI      |       | 116.80 | zone equation + country elec ef |
      | US      |       |  78.88 | zone equation + country elec ef |
      |         | CA    |  78.88 | zone equation + country elec ef |

  Scenario Outline: Calculations with fuel use equations not using climate zone
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "property_rooms" of "<rooms>"
    And it has "property_construction_year" of "<year>"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "<carbon>"
    Examples:
      | rooms | year | carbon | notes |
      |  25   | 1910 |  59.69 | rm yr equation |
      |  25   |      |  90.33 | rm equation |
      |       | 1910 |  66.60 | yr equation |
      |  75   | 1983 |  55.09 | rm yr equation |
      |  75   |      | 101.21 | rm equation |
      |       | 1983 |  63.67 | yr equation |
      | 500   | 2011 | 149.99 | rm yr equation |
      | 500   |      | 231.99 | rm equation |
      |       | 2011 |  66.66 | yr equation |
      |       |      | 100.25 | fallback equation |

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
      | 94122 |  25   | 1910 |  45.00 | zone rm yr equation + egrid elec ef |
      | 94122 |  25   |      |  40.76 | zone rm equation + egrid elec ef |
      | 94122 |       | 1910 |  54.39 | zone yr equation + egrid elec ef |
      | 94122 |  75   | 1983 |  59.87 | zone rm yr equation + egrid elec ef |
      | 94122 |  75   |      |  46.76 | zone rm equation + egrid elec ef |
      | 94122 |       | 1983 |  77.33 | zone yr equation + egrid elec ef |
      | 94122 | 500   | 2011 | 228.70 | zone rm yr equation + egrid elec ef |
      | 94122 | 500   |      | 141.11 | zone rm equation + egrid elec ef |
      | 94122 |       | 2011 |  92.58 | zone yr equation + egrid elec ef |
      | 94122 |       |      |  48.16 | zone equation + egrid elec ef |

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
      | Hilton San Francisco  |       | San Francisco | CA    | 101.55 | zone rm yr equation + country elec ef |
      | Hilton San Francisco  | 94122 |               |       | 57.78  | zone rm yr equation + egrid elec ef |
      | Courtyard by Marriott |       | San Francisco | CA    | 123.13 | zone rm yr equation + country elec ef |
      | Courtyard by Marriott | 94122 | San Francisco | CA    | 69.37  | zone rm yr equation + egrid elec ef |
      | Pacific Inn           |       | San Francisco | CA    | 78.88  | zone equation + country elec ef |
      | Pacific Inn           | 94122 | San Francisco | CA    | 48.16  | zone equation + egrid elec ef |
