require 'spec_helper'

describe ApplicationHelper do
  describe '#display_flash_messages' do
    context 'the messages checked for' do
      subject { ApplicationHelper::FLASH_MESSAGES_TO_DISPLAY }

      [ :message, :warning, :error ].each do |message|
        it "includes #{ message.inspect }" do
          subject.should include(message)
        end
      end
    end

    context 'displays correct content' do
      before(:each) do
        helper.output_buffer = ''
      end

      it 'does not display any content if there are no flash messages' do
        helper.display_flash_messages
        helper.output_buffer.should_not have_tag('#flash')
      end
      
      ApplicationHelper::FLASH_MESSAGES_TO_DISPLAY.each do |key|
        it "displays the flash[#{ key.inspect }] value" do
          flash[ key ] = 'THE MESSAGE'
          helper.display_flash_messages
          helper.output_buffer.should have_tag("#flash .#{ key }", :text => 'THE MESSAGE')
        end
      end

      it 'displays all of the flash messages that are present' do
        ApplicationHelper::FLASH_MESSAGES_TO_DISPLAY.each { |key| flash[ key ] = "MESSAGE FOR #{ key }" }
        helper.display_flash_messages
        helper.output_buffer.should have_tag('#flash') do |flash_messages|
          ApplicationHelper::FLASH_MESSAGES_TO_DISPLAY.each do |key|
            flash_messages.should have_tag(".#{ key }", :text => "MESSAGE FOR #{ key }")
          end
        end
      end
    end
  end
end
