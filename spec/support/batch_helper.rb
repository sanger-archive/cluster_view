module BatchHelper
  VALID_BATCH_ID = 5555.to_s
  INVALID_BATCH_ID = 666.to_s

  FAKE_VALID_BATCH_XML = <<-END_OF_FAKE_BATCH_XML
  <?xml version="1.0" encoding="utf-8"?>
  <batch>
    <id>#{ VALID_BATCH_ID }</id>
    <status>pending</status>
    <lanes>
      <lane position="1"><library name="sample from library 1"/></lane>
      <lane position="2"><library name="sample from library 2"/></lane>
      <lane position="3"><library name="sample from library 3"/></lane>
      <lane position="4"><control name="control sample"/></lane>
      <lane position="5"><library name="sample from library 5"/></lane>
      <lane position="6"><library name="sample from library 6"/></lane>
      <lane position="7"><library name="sample from library 7"/></lane>
      <lane position="8"><library name="sample from library 8"/></lane>
    </lanes>
  </batch>
  END_OF_FAKE_BATCH_XML
  
  def self.included(base)
    base.instance_eval do
      before(:each) do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/batches/#{VALID_BATCH_ID}.xml", {}, FAKE_VALID_BATCH_XML
          mock.get "/batches/#{INVALID_BATCH_ID}.xml", {}, nil, 404
        end
      end
    end
  end  
end
