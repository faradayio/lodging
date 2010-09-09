Feature: Lodging Emissions Calculations
  The lodging model should generate correct emission calculations

  Scenario: Standard Calculations for lodgings
    Given a lodging
    When emissions are calculated
    Then the emission value should be 1
