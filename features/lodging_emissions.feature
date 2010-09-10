Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When emissions are calculated
    Then the emission value should be within "0.01" kgs of "9.51"

  Scenario: Calculations starting from magnitude
    Given a lodging has "magnitude" of "5"
    When emissions are calculated
    Then the emission value should be within "0.1" kgs of "47.6"
