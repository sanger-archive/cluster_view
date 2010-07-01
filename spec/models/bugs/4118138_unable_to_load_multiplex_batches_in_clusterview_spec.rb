require 'spec_helper'

# The multiplex batch has a very different looking XML file which needs to be handled by the
# sample extraction code.
describe Batch do
  include BatchHelper

  describe '#samples' do
    before(:each) do
      @batch = described_class.find(BatchHelper::MULTIPLEX_BATCH_ID)
    end

    it 'returns the correct sample information' do
      @batch.samples.inject([]) { |a,s| a[ s.lane-1 ] = s.name ; a }.should == (1..8).map { |l| "sample pool #{ l }" }
    end
  end
end
