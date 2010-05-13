require 'spec_helper'

describe Filters do
  describe '.ConvertArrayParameter' do
    before(:each) do
      @controller = mock('Controller')
    end

    after(:each) do
      @controller.stub!(:params).and_return(@params)
      @filter.call(@controller)
      @params.should == @expected
    end

    it 'converts a top level hash parameter to an array' do
      @filter   = Filters::ConvertArrayParameter(:array)
      @params   = { :array => { '0' => '1st', '1' => '2nd', '2' => '3rd' } }
      @expected = { :array => [ '1st', '2nd', '3rd' ] } 
    end

    it 'does nothing if the parameter does not exist' do
      @filter = Filters::ConvertArrayParameter(:array)
      @params = @expected = { :not_array => { '0' => '1st' } }
    end

    it 'converts a nested level parameter' do
      @filter   = Filters::ConvertArrayParameter(:root, :child, :array)
      @params   = { :root => { :child => { :array => { '0' => '1st', '1' => 'last' } } } }
      @expected = { :root => { :child => { :array => [ '1st', 'last' ] } } }
    end

    it 'does nothing if the parameter path does not exist' do
      @filter = Filters::ConvertArrayParameter(:root, :child, :array)
      @params = @expected = { :root => { :array => { '0' => '1st', '1' => 'last' } } }
    end
  end

  describe '.PrepareObjectFilter' do
    before(:each) do
      @model_class, @controller = mock('Model', :name => 'MockModel'), mock('controller')
      @controller.stub!(:params).and_return(:model_id => 11111)
      @controller.stub_chain(:logger, :debug)
      @filter = Filters::PrepareObjectFilter(@model_class, :model_id)
    end

    it 'sets the member variable when the object is found' do
      @model_class.should_receive(:find).with(11111).and_return(:object_found)
      @filter.call(@controller)
      @controller.instance_variable_get('@mock_model').should == :object_found
    end

    [ ActiveRecord::RecordNotFound, ActiveResource::ResourceNotFound ].each do |exception|
      it "leaves the controller to deal with the #{ exception.name } exception" do
        @model_class.should_receive(:find).with(11111).and_raise(exception.new('something'))
        @controller.should_receive(:handle_mock_model_not_found_for).with(11111)
        @filter.call(@controller)
      end
    end
  end
end
