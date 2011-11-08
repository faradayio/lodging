Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Background:
    Given a Lodging

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "27.80"

  Scenario: Calculations starting from rooms
    Given it has "rooms" of "5"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "138.98"

  Scenario: Calculations starting from duration
    Given it has "duration" of "432000"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "138.98"

  Scenario: Calculations starting from lodging class
    Given it has "lodging_class.name" of "Hotel"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "42.58"

  Scenario: Calculations starting from state
    Given it has "state.postal_abbreviation" of "CA"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "22.15"

  Scenario: Calculations starting from zip code
    Given it has "zip_code.name" of "94122"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "12.48"

  Scenario: Calculations starting from rooms, duration, and lodging class
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "lodging_class.name" of "Hotel"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "170.34"

  Scenario: Calculations starting from rooms, duration, and state
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "state.postal_abbreviation" of "CA"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "88.61"

  Scenario: Calculations starting from rooms, duration, and zip code
    Given it has "rooms" of "2"
    And it has "duration" of "172800"
    And it has "zip_code.name" of "94122"
    When impacts are calculated
    Then the amount of "carbon" should be within "0.01" of "49.91"
