Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "13.7"

  Scenario: Calculations starting from rooms
    Given a lodging has "rooms" of "5"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "68.7"

  Scenario: Calculations starting from nights
    Given a lodging has "nights" of "5"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "68.7"

  Scenario: Calculations starting from lodging class
    Given a lodging has "lodging_class.name" of "Luxury Hotel"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "27.5"

  Scenario: Calculations starting from state
    Given a lodging has "state.postal_abbreviation" of "CA"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "10.0"

  Scenario: Calculations starting from zip code
    Given a lodging has "zip_code.name" of "94122"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "5.8"

  Scenario: Calculations starting from rooms, nights, and lodging class
    Given a lodging has "rooms" of "2"
    And it has "nights" of "2"
    And it has "lodging_class.name" of "Luxury Hotel"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "110.0"

  Scenario: Calculations starting from rooms, nights, and state
    Given a lodging has "rooms" of "2"
    And it has "nights" of "2"
    And it has "state.postal_abbreviation" of "CA"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "40.0"

  Scenario: Calculations starting from rooms, nights, and zip code
    Given a lodging has "rooms" of "2"
    And it has "nights" of "2"
    And it has "zip_code.name" of "94122"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "23.3"
