Feature: Lodging Committee Calculations
  The lodging model should generate correct committee calculations

  Scenario: Magnitude committee from default
    Given a lodging emitter
    When the "magnitude" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should be "1"

  Scenario: Lodging class committee from nothing
    Given a lodging emitter
    When the "lodging_class" committee is calculated
    Then the committee should have used quorum "default"
    And the conclusion of the committee should have "name" of "Average"

  Scenario: Emission factor committee from nothing
    Given a lodging emitter
    When the "lodging_class" committee is calculated
    And the "emission_factor" committee is calculated
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "1.5"

  Scenario: Emission factor committee from lodging class
    Given a lodging emitter
    And a characteristic "lodging_class.name" of "Luxury Hotel"
    When the "emission_factor" committee is calculated
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "2.0"
