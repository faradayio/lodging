require 'fuzzy_infer'

class CommercialBuildingEnergyConsumptionSurveyResponse < ActiveRecord::Base
  fuzzy_infer :target     => [:natural_gas_per_room_night, :fuel_oil_per_room_night, :electricity_per_room_night, :district_heat_per_room_night], # list of columns that this model is designed to infer
              :basis      => [:heating_degree_days, :cooling_degree_days, :lodging_rooms, :floors, :construction_year, :percent_cooled],          # list of columns that are believed to affect energy use (aka MU)
              :sigma      => "(STDDEV_SAMP(:column)/5)+(ABS(AVG(:column)-:value)/3)",                                                             # empirically determined formula (SQL!) that captures the desired sample size once all the weights are compiled, across the full range of possible mu values
              :membership => :energy_use_membership,                                                                                              # name of instance method to be called on kernel
              :weight     => :weighting                                                                                                           # (optional) a pre-existing row weighting, if any, provided by the dataset authors
  
  # empirically determined formula that minimizes variance between real and predicted energy use
  # SQL! - :heating_degree_days_n_w will be replaced with, for example, `tmp_table_9301293.hdd_normalized_weight`
  def energy_use_membership(basis)
    keys = basis.keys
    
    unless keys.include?(:heating_degree_days) and keys.include?(:cooling_degree_days)
      raise ArgumentError, "[lodging] Must provide at least :heating_degree_days and :cooling_degree_days"
    end
    
    formula = ['(POW(:heating_degree_days_n_w, 0.8) + POW(:cooling_degree_days_n_w, 0.8))']
    if keys.include?(:lodging_rooms) and keys.include?(:floors)
      formula << '(POW(:lodging_rooms_n_w, 0.8) + POW(:floors_n_w, 0.8))'
    elsif keys.include? :lodging_rooms
      formula << 'POW(:lodging_rooms_n_w, 0.8)'
    elsif keys.include? :floors
      formula << 'POW(:floors_n_w, 0.8)'
    end
    formula << 'POW(:percent_cooled_n_w, 0.8)' if keys.include?(:percent_cooled)
    formula << 'POW(:construction_year_n_w, 0.8)' if keys.include?(:construction_year)
    formula.join(' * ')
  end
end
