require 'summary_judgement'

module BrighterPlanet
  module Lodging
    module Summarization
      def self.included(base)
        base.extend SummaryJudgement
        base.summarize do |has|
          has.identity 'lodging'
        end
      end
    end
  end
end
