module NamedScopeHelper
  def it_has_conditions(*conditions)
    it 'limits by conditions' do
      should == { :conditions => conditions }
    end
  end
  
  def using_named_scope(scope, *args, &block)
    describe ".#{ scope }" do
      subject { described_class.send(scope, *args).proxy_options }
      instance_eval(&block)
    end
  end
  
  def mock_object_with_id(id)
    object = Object.new
    object.instance_eval("def id ; #{ id.inspect } ; end")
    object
  end
end

class Spec::Rails::Example::ModelExampleGroup
  class << self
    def describe_named_scopes(&block)
      describe 'named scopes' do
        extend NamedScopeHelper
        instance_eval(&block)
      end
    end
  end
end
