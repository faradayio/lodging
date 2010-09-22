module BrighterPlanet
  module Lodging
    module Summarization
      def self.included(base)
        base.summarize do |has|
          has.identity 'lodging'
        end
      end
    end
  end
end
