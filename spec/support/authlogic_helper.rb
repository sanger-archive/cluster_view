require 'authlogic/test_case'

module Authlogic
  module RSpec
    module Matchers
      def session_should_not_be_logged_in
        UserSession.find.should be_nil
      end

      def session_should_be_logged_in_as(record)
        UserSession.find.record == record
      end
    end
  end

  module FactoryGirl
    def self.included(base)
      base.alias_method_chain(:Factory, :authlogic_session)
    end

    # Override the behaviour of Factory Girl so that we can log out the user once they are created.
    def Factory_with_authlogic_session(*args)
      options = { :log_out => false }.update(args.extract_options!)
      log_out_instance = options.delete(:log_out)
      args.push(options)
      record = Factory_without_authlogic_session(*args)
      UserSession.find.destroy if log_out_instance
      record
    end
  end
end

module Spec
  module Rails
    module Example
      class ViewExampleGroup
        include Authlogic::RSpec::Matchers
        include Authlogic::FactoryGirl

        before(:each) do
          activate_authlogic
          Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::RailsAdapter.new(@controller)
        end
      end

      class ControllerExampleGroup
        include Authlogic::RSpec::Matchers
        include Authlogic::FactoryGirl

        before(:each) do
          activate_authlogic
        end
      end
    end
  end if const_defined?('Rails')
end
