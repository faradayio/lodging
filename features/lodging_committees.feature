Feature: Lodging Committee Calculations
  The lodging model should generate correct committee calculations

  Scenario: Magnitude committee from default
    Given a lodging emitter
    When the "magnitude" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be ""

  Scenario: Emission factor committee from default
    Given a lodging emitter
    When the "emission_factor" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be ""

  Scenario: Emission committee from nothing
    Given a lodging emitter
    When the "magnitude" committee is calculated
    And the "emission_factor" committee is calculated
    And the "emission" committee is calculated
    Then the committee should have used quorum "from magnitude and emission factor"
    And the conclusion of the committee should be ""
