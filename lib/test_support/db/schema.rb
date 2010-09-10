require 'sniff/database'

Sniff::Database.define_schema do
  create_table "lodging_records", :force => true do |t|
    t.integer 'magnitude'
  end
end
