Factory.define('Images for batch', :class => Image) do |image|
  image.sequence(:data_file_name) { |n| "%03i" % n }
  image.sequence(:position) { |n| n }
  image.data_file "ORIGINAL IMAGE FILE"
  image.data_content_type "ORINGINAL IMAGE TYPE"
  image.data_thumbnail_file "THUMBNAIL IMAGE FILE"
end
