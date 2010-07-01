# Seems factory_girl isn't getting properly pulled in when run within Bundler
require 'factory_girl'
Dir[File.join(File.dirname(__FILE__), %w{.. .. spec factories ** *.rb})].each do |factory_file|
  require factory_file
end
