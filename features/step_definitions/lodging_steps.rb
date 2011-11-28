Given /^the geocoder will encode the (.*) as "(.*)" with zip code "(.*)", state "(.*)", and country "(.*)"$/ do |component, location, zip, state, country|
  @expectations << lambda do
    components = @characteristics ? @characteristics : @activity_hash
    component_value = components[component.to_sym].to_s
    code = mock Object, :success => true, :ll => location, :zip => zip, :state => state, :country_code => country
    Geokit::Geocoders::MultiGeocoder.stub!(:geocode).with(component_value).and_return code
  end
end

Given /^the geocoder will fail to encode the (.*)$/ do |component|
  @expectations << lambda do
    components = @characteristics ? @characteristics : @activity_hash
    component_value = components[component.to_sym].to_s
    code = mock Object, :success => false
    Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).with(component_value).and_return code
  end
end
