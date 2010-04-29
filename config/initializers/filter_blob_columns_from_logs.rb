# We're using blob columns for our images and thumbnails and, let's face it, it's really annoying
# that they get displayed in the log files.  This simply hides those columns.
class ActiveRecord::ConnectionAdapters::AbstractAdapter
  def format_log_entry_with_blob_filtering(message, dump = nil)
    dump = case
    when /^INSERT INTO "?images"?/ =~ dump.to_s then 'INSERT INTO "images" (*** image data hidden ***)'
    when /^UPDATE "?images"?/ =~ dump.to_s      then 'UPDATE "images" (*** image data hidden ***)'
    else dump
    end
    format_log_entry_without_blob_filtering(message, dump)
  end
  alias_method_chain(:format_log_entry, :blob_filtering)
end

