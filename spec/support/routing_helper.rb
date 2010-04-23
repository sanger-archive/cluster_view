module RoutingHelper
  ALL_HTTP_METHODS = [ :get, :put, :post, :delete ]
  ALL_HTTP_METHODS.each { |method| const_set(:"HTTP_#{ method.to_s.upcase }_ONLY", [ method ]) }

  # Validates that the specified HTTP request method to the given path results in the expected route.
  def permitted_routing_to(request_method, path, expected_route)
    it "permits #{ request_method.to_s.upcase } to #{ expected_route.inspect }" do
      params_from(request_method, path).should == expected_route
    end
  end

  # Validates that the specified HTTP request method to the given path fails.
  def denied_routing_to(request_method, path, expected_route)
    it "denies #{ request_method.to_s.upcase } to #{ expected_route.inspect }" do
      lambda { params_from(request_method, path) }.should raise_error(ActionController::MethodNotAllowed)
    end
  end

  # Validates that the specified HTTP request methods are permitted to given path and result in the
  # expected route.  HTTP request methods not specified are assumed to not be permitted and those
  # cases are validated.
  def routing_to(path, expected_route, permitted_methods = ALL_HTTP_METHODS)
    ALL_HTTP_METHODS.each do |request_method|
      routing_check = permitted_methods.include?(request_method) ? :permitted : :denied
      send(:"#{ routing_check }_routing_to", request_method, path, expected_route)
    end
  end
end

class Spec::Rails::Example::ControllerExampleGroup
  def self.check_routing(&block)
    context 'routing' do
      extend RoutingHelper
      instance_eval(&block)
    end
  end
end
