# We're using blob columns for our images and thumbnails and, let's face it, it's really annoying
# that they get displayed in the log files.  This simply hides those columns.
class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def format_log_entry_with_blob_filtering(message, dump = nil)
    if dump.try(:length).to_i > 400 && dump.match(/[\x80-\xff]/)
      dump = dump[0,dump.index(/[\x80-\xff]/)] + "...[***truncating #{dump.length} bytes of SQL statement***]'"
    end
    format_log_entry_without_blob_filtering(message, dump)
  end
  alias_method_chain(:format_log_entry, :blob_filtering)
end

