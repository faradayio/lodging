require 'data_miner'

module BrighterPlanet
  module Lodging
    module Data
      def self.included(base)
        base.data_miner do
          schema do
            string  'lodging_class_name'
            integer 'magnitude'
          end

          process :run_data_miner_on_belongs_to_associations
        end
      end
    end
  end
end
