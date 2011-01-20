# Do not swallow the errors produced by ImageMagick convert
Paperclip.options[:swallow_stderr] = false 
# Do not panic because a TIFF might have unregistered property fields
Paperclip.options[:whiny] = false 
