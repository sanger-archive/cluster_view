class Batch < ActiveResource::Base
  self.site = Settings.sequencescape_url
end
