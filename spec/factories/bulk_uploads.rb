Factory.define('Bulk upload', :class => BulkUpload) do |bulk|
  bulk.images do |images| 
    (0..15).map { |index| Factory('Bulk upload image', :data_file_name => "#{ index }.tif") }
  end
end
Factory.define('Bulk upload image', :class => Image) do |image|
  image.sequence(:position) { |index| index % 16 }
end
