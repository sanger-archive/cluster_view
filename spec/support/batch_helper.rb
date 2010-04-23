module BatchHelper
  VALID_BATCH_ID = 5555
  INVALID_BATCH_ID = 666
  
  def self.included(base)
    base.instance_eval do
      before(:each) do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/batches/#{VALID_BATCH_ID}.xml", {}, {:id => VALID_BATCH_ID}.to_xml(:root => "batch")
          mock.get "/batches/#{INVALID_BATCH_ID}.xml", {}, nil, 404
        end
      end
    end
  end  
end
