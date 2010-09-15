Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When emissions are calculated
    Then the emission value should be within "0.00001" kgs of "11.24496"

  Scenario: Calculations starting from rooms
    Given a lodging has "rooms" of "5"
    When emissions are calculated
    Then the emission value should be within "0.00001" kgs of "56.22478"

  Scenario: Calculations starting from nights
    Given a lodging has "nights" of "5"
    When emissions are calculated
    Then the emission value should be within "0.00001" kgs of "56.22478"

  Scenario: Calculations starting from lodging class
    Given a lodging has "lodging_class.name" of "Luxury Hotel"
    When emissions are calculated
    Then the emission value should be within "0.00001" kgs of "22.48991"

  Scenario: Calculations starting from rooms, nights, and lodging class
    Given a lodging has "rooms" of "2"
    And it has "nights" of "2"
    And it has "lodging_class.name" of "Luxury Hotel"
    When emissions are calculated
    Then the emission value should be within "0.00001" kgs of "89.95965"
