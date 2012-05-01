# LodgingProperty is defined in CM1 rather than Earth, so we need to define it here for testing
class LodgingProperty < ActiveRecord::Base
  col :northstar_id
  col :name
  col :city
  col :locality # state / province / etc.
  col :postcode # zip code / postal code / etc.
  col :country_iso_3166_alpha_3_code
  col :chain_name
  col :lodging_rooms,     :type => :integer
  col :floors,            :type => :integer
  col :construction_year, :type => :integer
  col :lodging_class_name
  col :ac_coverage,       :type => :float
  col :mini_bar_coverage, :type => :float
  col :fridge_coverage,   :type => :float
  col :hot_tubs,          :type => :float # float b/c fallback needs to be a float
  col :pools_indoor,      :type => :float # float b/c fallback needs to be a float
  col :pools_outdoor,     :type => :float # float b/c fallback needs to be a float
  
  # based on LodgingProperty as of 2012-02-21
  falls_back_on :fridge_coverage => 0.6,
                :hot_tubs        => 0.3,
                :pools_indoor    => 0.3,
                :pools_outdoor   => 0.6
end
