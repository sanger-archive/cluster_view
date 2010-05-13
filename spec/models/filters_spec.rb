require 'spec_helper'

describe Filters do
  describe '.PrepareObjectFilter' do
    before(:each) do
      @model_class, @controller = mock('Model', :name => 'MockModel'), mock('controller')
      @controller.stub!(:params).and_return(:model_id => 11111)
      @controller.stub_chain(:logger, :debug)
      @filter = Filters::PrepareObjectFilter(@model_class, :model_id)
    end

    it 'returns an object that responds_to?(:filter)' do
      @filter.should respond_to(:filter)
    end

    it 'sets the member variable when the object is found' do
      @model_class.should_receive(:find).with(11111).and_return(:object_found)
      @filter.filter(@controller)
      @controller.instance_variable_get('@mock_model').should == :object_found
    end

    [ ActiveRecord::RecordNotFound, ActiveResource::ResourceNotFound ].each do |exception|
      it "leaves the controller to deal with the #{ exception.name } exception" do
        @model_class.should_receive(:find).with(11111).and_raise(exception.new('something'))
        @controller.should_receive(:handle_mock_model_not_found_for).with(11111)
        @filter.filter(@controller)
      end
    end
  end
end
