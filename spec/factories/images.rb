Factory.define('Images for batch', :class => Image) do |image|
  image.sequence(:filename) { |n| "%03i" % n }
  image.sequence(:position) { |n| n }
end
