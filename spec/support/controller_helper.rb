class Spec::Rails::Example::ControllerExampleGroup
  class << self
    def it_should_fall_through_the_following_actions(*actions)
      actions.each do |action|
        describe "GET '#{ action }'" do
          it 'should be successful' do
            get action
            response.should be_success
          end
        end
      end
    end
  end
end
