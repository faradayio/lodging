ENV.each do |name, value|
  if /^LOCAL_(.+)/.match(name)
    gem $1.downcase, :path => value
  end
end

source :rubygems

gemspec :path => '.'
gem 'sniff', :git => 'git://github.com/brighterplanet/sniff.git', :branch => 'nicer_db'
gem 'fuzzy_infer', :git => 'git://github.com/seamusabshere/fuzzy_infer.git'
