require 'paperclip'

# There is a problem with the altered implementation of Paperclip that means that it'll fall over
# in a big heap if the table does not exist (think before migrations are run!) because it checks 
# the columns.  This simply overrides the default behaviour so that check is not done.
module Paperclip
  module ClassMethods
    def setup_file_columns(name)
      (attachment_definitions[name][:file_columns] = file_columns(name)).each do |style,column|
        raise PaperclipError.new("#{ name } is not an allowed column name; please choose another column name.") if column == name.to_s
      end
    end
  end
end
