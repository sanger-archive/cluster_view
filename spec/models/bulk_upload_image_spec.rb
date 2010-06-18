require 'spec_helper'

describe BulkUploadImage do
  describe_named_scopes do
    using_named_scope(:in_position, :position) do
      it_has_conditions('position=?', :position)
    end
  end
end
