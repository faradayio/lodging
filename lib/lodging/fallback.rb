module BrighterPlanet
  module Lodging
    module Fallback
      def self.included(base)
        base.falls_back_on :rooms  => 1,
                           :nights => 1
      end
    end
  end
end
