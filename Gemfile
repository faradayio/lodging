ENV.each do |name, value|
  if /^LOCAL_(.+)/.match(name)
    gem $1.downcase, :path => value
  end
end

source :rubygems

gemspec :path => '.'

gem 'earth', :git => 'git://github.com/brighterplanet/earth.git', :branch => 'electricity_mix'
