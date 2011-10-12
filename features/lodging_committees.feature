Feature: Lodging Committee Calculations
  The lodging model should generate correct committee calculations

  Background:
    Given a Lodging

  Scenario: Rooms committee from default
    Given the conclusion of the committee should be "1.0"

  Scenario: Duration committee from default
    Given the conclusion of the committee should be "86400"

  Scenario: State committee from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "state" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "postal_abbreviation" of "CA"

  Scenario: Census division committee from state
    Given a characteristic "state.postal_abbreviation" of "CA"
    When the "census_division" committee reports
    Then the committee should have used quorum "from state"
    And the conclusion of the committee should have "number" of "9"

  Scenario: eGRID subregion from nothing
    Given the conclusion of the committee should have "abbreviation" of "US"

  Scenario: eGRID subregion from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "egrid_subregion" committee reports
    Then the committee should have used quorum "from zip code"
    And the conclusion of the committee should have "abbreviation" of "CAMX"

  Scenario: eGRID region from nothing
    Given the "egrid_region" committee reports
    Then the committee should have used quorum "from eGRID subregion"
    And the conclusion of the committee should have "name" of "US"

  Scenario: eGRID region from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "egrid_subregion" committee reports
    And the "egrid_region" committee reports
    Then the committee should have used quorum "from eGRID subregion"
    And the conclusion of the committee should have "name" of "W"

  Scenario: Lodging class committee from nothing
    Given the conclusion of the committee should have "name" of "Average"

  Scenario: District heat intensity committee from nothing
    Given the "district_heat_intensity" committee reports
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "4.0"

  Scenario: District heat intensity committee from lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    When the "district_heat_intensity" committee reports
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "2.0"

  Scenario: District heat intensity committee from census division
    Given a characteristic "census_division.number" of "9"
    When the "district_heat_intensity" committee reports
    Then the committee should have used quorum "from census division"
    And the conclusion of the committee should be "2.0"

  Scenario: Electricity intensity committee from nothing
    Given the "electricity_intensity" committee reports
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "35.0"

  Scenario: Electricity intensity committee from lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    When the "electricity_intensity" committee reports
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "55.0"

  Scenario: Electricity intensity committee from census division
    Given a characteristic "census_division.number" of "9"
    When the "electricity_intensity" committee reports
    Then the committee should have used quorum "from census division"
    And the conclusion of the committee should be "30.0"

  Scenario: Fuel oil intensity committee from nothing
    Given the "fuel_oil_intensity" committee reports
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "0.5"

  Scenario: Fuel oil intensity committee from lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    When the "fuel_oil_intensity" committee reports
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "0.25"

  Scenario: Fuel oil intensity committee from census division
    Given a characteristic "census_division.number" of "9"
    When the "fuel_oil_intensity" committee reports
    Then the committee should have used quorum "from census division"
    And the conclusion of the committee should be "0.0"

  Scenario: Natural gas intensity committee from nothing
    Given the "natural_gas_intensity" committee reports
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "2.0"

  Scenario: Natural gas intensity committee from lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    When the "natural_gas_intensity" committee reports
    Then the committee should have used quorum "from lodging class"
    And the conclusion of the committee should be "3.5"

  Scenario: Natural gas intensity committee from census division
    Given a characteristic "census_division.number" of "9"
    When the "natural_gas_intensity" committee reports
    Then the committee should have used quorum "from census division"
    And the conclusion of the committee should be "1.5"

  Scenario: Emission factor committee from nothing
    Given the "egrid_region" committee reports
    And the "lodging_class" committee reports
    And the "district_heat_intensity" committee reports
    And the "electricity_intensity" committee reports
    And the "fuel_oil_intensity" committee reports
    And the "natural_gas_intensity" committee reports
    And the "emission_factor" committee reports
    Then the committee should have used quorum "from fuel intensities and eGRID"
    And the conclusion of the committee should be "27.79608"

  Scenario: Emission factor committee from lodging class
    Given a characteristic "lodging_class.name" of "Hotel"
    When the "egrid_subregion" committee reports
    And the "egrid_region" committee reports
    And the "district_heat_intensity" committee reports
    And the "electricity_intensity" committee reports
    And the "fuel_oil_intensity" committee reports
    And the "natural_gas_intensity" committee reports
    And the "emission_factor" committee reports
    Then the committee should have used quorum "from fuel intensities and eGRID"
    And the conclusion of the committee should be "42.58421"

  Scenario: Emission factor committee from census division
    Given a characteristic "census_division.number" of "9"
    When the "egrid_subregion" committee reports
    And the "egrid_region" committee reports
    And the "district_heat_intensity" committee reports
    And the "electricity_intensity" committee reports
    And the "fuel_oil_intensity" committee reports
    And the "natural_gas_intensity" committee reports
    And the "emission_factor" committee reports
    Then the committee should have used quorum "from fuel intensities and eGRID"
    And the conclusion of the committee should be "22.15176"

  Scenario: Emission factor committee from zip code
    Given a characteristic "zip_code.name" of "94122"
    When the "state" committee reports
    And the "census_division" committee reports
    And the "egrid_subregion" committee reports
    And the "egrid_region" committee reports
    And the "district_heat_intensity" committee reports
    And the "electricity_intensity" committee reports
    And the "fuel_oil_intensity" committee reports
    And the "natural_gas_intensity" committee reports
    And the "emission_factor" committee reports
    Then the committee should have used quorum "from fuel intensities and eGRID"
    And the conclusion of the committee should be "12.47651"
