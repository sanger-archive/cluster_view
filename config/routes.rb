ActionController::Routing::Routes.draw do |map|
  map.with_options(:controller => 'site', :conditions => { :method => :get }) do |site|
    site.about('/about', :action => 'about')
    site.feedback('/feedback', :action => 'feedback')
  end

  map.with_options(:controller => 'bulk_upload', :conditions => { :method => :get }) do |bulk_upload|
    bulk_upload.bulk_start('/bulk_upload/start/:id', :action => 'start')
    bulk_upload.bulk_cancel('/bulk_upload/:id/cancel', :action => 'cancel', :requirements => { :id => /\d+/ })
    
    bulk_upload.with_options(:requirements => { :id => /\d+/ }) do |during_upload|
      during_upload.bulk_upload('/bulk_upload/:id/upload', :action => 'upload', :conditions => { :method => :put })
      during_upload.bulk_finish('/bulk_upload/:id/finish/:batch_id', :action => 'finish')
    end
  end

  map.with_options(:controller => 'batches', :conditions => { :method => :get }, :requirements => { :image_id => /\d+/ }) do |images|
    images.batch_thumbnail('/thumbnails/:id/:image_id', :action => 'thumbnail')
    images.batch_image('/images/:id/:image_id', :action => 'image')
  end
  map.with_options(:controller => 'batches', :conditions => { :method => :get }) do |batches|
    batches.root :action => 'index'
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
