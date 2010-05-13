require 'spec_helper'

describe BatchesController::ImageSendingFacade do
  before(:each) do
    @controller = mock('controller')
    @facade = BatchesController::ImageSendingFacade.new(@controller)
  end

  describe '#error_as_no_data_for' do
    it 'sends a 404 Not Found' do
      @controller.should_receive(:render).with(hash_including(:status => :not_found))
      @facade.error_as_no_data_for(:image)
    end
  end

  describe '#send_data' do
    it 'passes through to the controller' do
      @controller.should_receive(:send_data).with(:data_source, :options)
      @facade.send_data(:data_source, :options)
    end
  end
end
