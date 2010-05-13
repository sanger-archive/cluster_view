module Filters
  # Returns a controller filter that will turn the specified parameter from a Hash that has numeric keys to
  # an Array, setup as those numeric keys specify.
  def self.ConvertArrayParameter(*parameter_path)
    last_step = parameter_path.pop

    lambda do |controller|
      controller.instance_eval do
        final_hash = parameter_path.inject(params) { |parameters,step| parameters.try(:[], step) }
        unless final_hash.nil? or (original_hash = final_hash[ last_step ]).nil?
          final_hash[ last_step ] = original_hash.inject([]) { |a,(index,value)| a[ index.to_i ] = value ; a }
        end
      end
    end
  end

  # This method creates a controller filter that can be used to populate a member variable with an ActiveRecord
  # or ActiveResource object based on a specified parameter value.  For instance:
  #
  #   class MyController
  #     before_filter Filters::PrepareObjectFilter(MyModel, :model_id)
  #   end
  #
  # Will effectively do <tt>@my_model = MyModel.find(params[ :model_id })</tt>.  If the object cannot be found
  # then the code will call +handle_MEMBER_VARIABLE_NAME_not_found_for+, passing the object ID used.  In the
  # example this would mean that +handle_my_model_not_found_for+ would be called.
  #
  # You can change the member variable name with the final parameter.
  def self.PrepareObjectFilter(object_class, parameter, member_variable_name = object_class.name.underscore)
    member_variable = :"@#{ member_variable_name }"
    error_handler   = :"handle_#{ member_variable_name }_not_found_for"

    lambda do |controller|
      controller.instance_eval do
        begin
          instance_variable_set(member_variable, object_class.find(object_id = params[ parameter ]))
        rescue ActiveRecord::RecordNotFound, ActiveResource::ResourceNotFound => exception
          logger.debug("The #{ object_class.name } could not be found from params[#{ parameter.inspect }] (id = #{ object_id.inspect })")
          send(error_handler, object_id)
        end
      end
    end
  end
end
