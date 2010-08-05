begin 
  require 'deployed_version'
rescue LoadError
  module Deployed
    VERSION_STRING = "#{File.split(Rails.root).last.capitalize} LOCAL [#{Rails.env}]"
  end
end
