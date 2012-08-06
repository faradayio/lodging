require 'bundler/setup'

require 'lodging'

require 'sniff/rake_tasks'
Sniff::RakeTasks.define_tasks

namespace :lodging do
  namespace :db do
    task :env do
      require_relative 'features/support/lodging_property'
    end
    task :migrate => :env do
      LodgingProperty.auto_upgrade!
    end
    task :seed => :env do
      LodgingProperty.delete_all
      CSV.foreach(File.expand_path('../features/support/db/fixtures/lodging_properties.csv', __FILE__), :headers => true) do |row|
        ActiveRecord::Base.connection.insert_fixture(row, 'lodging_properties')
      end
    end
  end
end

task 'db:migrate' => 'lodging:db:migrate'
task 'db:seed' => 'lodging:db:seed'
