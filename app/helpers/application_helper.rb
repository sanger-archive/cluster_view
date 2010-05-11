require 'formtastic_ext'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  FLASH_MESSAGES_TO_DISPLAY = [ :message, :warning, :error ]

  def display_flash_messages
    messages = FLASH_MESSAGES_TO_DISPLAY.select { |key| flash.key?(key) }
    concat(
      content_tag(
        :div, 
        messages.map { |key| content_tag(:p, h(flash[ key ]), :class => key) }.join,
        :id => 'flash'
      )
    ) unless messages.empty?
  end
end
