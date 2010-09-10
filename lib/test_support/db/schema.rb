require 'sniff/database'

Sniff::Database.define_schema do
  create_table "lodging_records", :force => true do |t|
    t.string  'lodging_class_name'
    t.integer 'magnitude'
  end
end
