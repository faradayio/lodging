Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Scenario: Calculations starting from nothing
    Given a lodging has nothing
    When emissions are calculated
    Then the emission value should be within "0.00001" kgs of "1.5"

  Scenario: Calculations starting from magnitude
    Given a lodging has "magnitude" of "5"
    When emissions are calculated
    Then the emission value should be within "0.00001" kgs of "7.5"

  Scenario: Calculations starting from lodging class
    Given a lodging has "lodging_class.name" of "Luxury Hotel"
    When emissions are calculated
    Then the emission value should be within "0.00001" kgs of "2.0"

  Scenario: Calculations starting from lodging class and magnitude
    Given a lodging has "lodging_class.name" of "Luxury Hotel"
    And it has "magnitude" of "5"
    When emissions are calculated
    Then the emission value should be within "0.00001" kgs of "10"
