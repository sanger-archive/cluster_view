class Spec::Rails::Example::HelperExampleGroup
  class << self
    def translation_method(method, l10n_key)
      describe "##{ method }" do
        it 'uses L10N for text message' do
          helper.should_receive(:translate).with(l10n_key).and_return(:ok)
          helper.send(method).should == :ok
        end
      end
    end
  end
end
