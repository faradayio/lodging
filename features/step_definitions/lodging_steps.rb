Given /^(a )?hash characteristic "(.*)" of "(.*)"$/ do |_, name, hash_string|
  hsh = hash_string.split(',').inject({}) do |memo, item|
    contents = item.split('=>')
    memo[contents[0].strip.to_sym] = coerce_value(contents[1].strip)
    memo
  end
  @characteristics[name.to_sym] = hsh
end

Then /^the "(.*)" committee should have key "(.*)" with value "(.*)"$/ do |committee, key, value|
  report_value = coerce_value @characteristics[committee.to_sym][key.to_sym]
  compare_values report_value, coerce_value(value)
end
