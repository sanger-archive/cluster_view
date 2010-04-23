require 'spec_helper'

describe Image do
  describe_named_scopes do
    def self.mock_batch
      mock_object_with_id('BATCH ID')
    end
    
    using_named_scope(:for_batch, mock_batch) do
      it_has_conditions('batch_id=?', 'BATCH ID')
    end
    
    using_named_scope(:by_batch_and_image_id, mock_batch, 'IMAGE ID') do
      it_has_conditions('batch_id=? AND id=?', 'BATCH ID', 'IMAGE ID')
    end
  end
end
