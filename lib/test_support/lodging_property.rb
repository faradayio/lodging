# LodgingProperty is defined in CM1 rather than Earth, so we need to define it here for testing
require 'earth/model'

class LodgingProperty < ActiveRecord::Base
    extend Earth::Model

    TABLE_STRUCTURE = <<-EOS

CREATE TABLE lodging_properties
  (
     northstar_id                       CHARACTER VARYING(255) NOT NULL PRIMARY KEY,
     name                               CHARACTER VARYING(255),
     city                               CHARACTER VARYING(255),
     locality                           CHARACTER VARYING(255),
     postcode                           CHARACTER VARYING(255),
     country_iso_3166_alpha_3_code      CHARACTER VARYING(255),
     lodging_rooms                      INTEGER,
     floors                             INTEGER,
     construction_year                  INTEGER,
     lodging_class_name                 CHARACTER VARYING(255),
     ac_coverage                        FLOAT,
     fridge_coverage                    FLOAT,
     mini_bar_coverage                  FLOAT,
     hot_tubs                           FLOAT,
     pools_indoor                       FLOAT,
     pools_outdoor                      FLOAT
  );

EOS
  
  # based on LodgingProperty as of 2012-02-21
  falls_back_on :fridge_coverage => 0.6,
                :hot_tubs        => 0.3,
                :pools_indoor    => 0.3,
                :pools_outdoor   => 0.6
end
