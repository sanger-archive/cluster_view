ActionController::Routing::Routes.draw do |map|
  map.with_options(:controller => 'site', :conditions => { :method => :get }) do |site|
    site.root :action => 'index'
    site.about('/about', :action => 'about')
    site.feedback('/feedback', :action => 'feedback')
  end

  map.with_options(:controller => 'batches', :conditions => { :method => :get }, :requirements => { :image_id => /\d+/ }) do |images|
    images.batch_thumbnail('/thumbnails/:id/:image_id', :action => 'thumbnail')
    images.batch_image('/images/:id/:image_id', :action => 'image')
  end
  map.with_options(:controller => 'batches', :conditions => { :method => :get }) do |batches|
    batches.batches('/batches', :action => 'index')
    batches.batch_search('/batches/search', :action => 'show')
    batches.batch('/batches/:id', :action => 'show')
    batches.batch_update('/batches/:id', :action => 'update', :conditions => { :method => :put })
  end

  map.with_options(:controller => 'user_sessions') do |authentication|
    authentication.login('/login', :action => 'new', :conditions => { :method => :get })
    authentication.logout('/logout', :action => 'destroy', :conditions => { :method => :get })
    authentication.new_session('/new_session', :action => 'create', :conditions => { :method => :post })
  end
end
