require 'coveralls'
Coveralls.wear_merged!
SimpleCov.merge_timeout 3600

require 'aruba/cucumber'
require 'aruba-doubles/cucumber'

Before do
  @aruba_timeout_seconds = 8
  # This is using the aruba helper, 
  # cf. https://github.com/cucumber/aruba/blob/master/lib/aruba/api.rb
  set_env('COVERAGE', 'true')
  # This could also be accomplished with the "I set the environment variables to:" step
end
