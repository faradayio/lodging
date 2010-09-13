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

  Scenario: District heat intensity committee from nothing
    Given a lodging emitter
    When the "lodging_class" committee is calculated
    And the "district_heat_intensity" committee is calculated
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "10000000"

  Scenario: District heat intensity committee from lodging class
    Given a lodging emitter
    And a characteristic "lodging_class.name" of "Luxury Hotel"
    When the "district_heat_intensity" committee is calculated
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "20000000"

  Scenario: Electricity intensity committee from nothing
    Given a lodging emitter
    When the "lodging_class" committee is calculated
    And the "electricity_intensity" committee is calculated
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "5"

  Scenario: Electricity intensity committee from lodging class
    Given a lodging emitter
    And a characteristic "lodging_class.name" of "Luxury Hotel"
    When the "electricity_intensity" committee is calculated
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "10"

  Scenario: Fuel oil intensity committee from nothing
    Given a lodging emitter
    When the "lodging_class" committee is calculated
    And the "fuel_oil_intensity" committee is calculated
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "0.5"

  Scenario: Fuel oil intensity committee from lodging class
    Given a lodging emitter
    And a characteristic "lodging_class.name" of "Luxury Hotel"
    When the "fuel_oil_intensity" committee is calculated
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "1"

  Scenario: Natural gas intensity committee from nothing
    Given a lodging emitter
    When the "lodging_class" committee is calculated
    And the "natural_gas_intensity" committee is calculated
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "1"

  Scenario: Natural gas intensity committee from lodging class
    Given a lodging emitter
    And a characteristic "lodging_class.name" of "Luxury Hotel"
    When the "natural_gas_intensity" committee is calculated
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "2"

  Scenario: Emission factor committee from nothing
    Given a lodging emitter
    When the "lodging_class" committee is calculated
    And the "district_heat_intensity" committee is calculated
    And the "electricity_intensity" committee is calculated
    And the "fuel_oil_intensity" committee is calculated
    And the "natural_gas_intensity" committee is calculated
    And the "emission_factor" committee is calculated
    Then the committee should have used quorum "from fuel intensities"
    And the conclusion of the committee should be "11.24496"

  Scenario: Emission factor committee from lodging class
    Given a lodging emitter
    And a characteristic "lodging_class.name" of "Luxury Hotel"
    When the "district_heat_intensity" committee is calculated
    And the "electricity_intensity" committee is calculated
    And the "fuel_oil_intensity" committee is calculated
    And the "natural_gas_intensity" committee is calculated
    And the "emission_factor" committee is calculated
    And the "emission_factor" committee is calculated
    Then the committee should have used quorum "from fuel intensities"
    And the conclusion of the committee should be "22.48991"
