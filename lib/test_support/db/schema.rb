require 'sniff/database'

Sniff::Database.define_schema do
  create_table "lodging_records", :force => true do |t|
    t.string  'lodging_class_name'
    t.string  'zip_code_name'
    t.string  'state_postal_abbreviation'
    t.integer 'rooms'
    t.integer 'nights'
  end
end
