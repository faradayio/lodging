Given %r{an association characteristic "(.*)" of "([^\"]*)"} do |name, value|
  characteristic_name, attribute = name.split /\./
  model = begin
    characteristic_name.singularize.camelize.constantize
  rescue NameError
    association = @activity.reflect_on_association characteristic_name.to_sym
    association.klass
  end
  @characteristics[characteristic_name.to_sym] ||= model.new
  @characteristics[characteristic_name.to_sym].send "#{attribute}=", coerce_value(value)
end
