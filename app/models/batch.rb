class Batch < ActiveResource::Base
  self.site = Settings.sequencescape_uri
end