ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'site', :action => 'index'

  map.with_options(:controller => 'batches', :conditions => { :method => :get }) do |batches|
    batches.batches('/batches', :action => 'index')
    batches.batch_search('/batches/search', :action => 'show')
    batches.batch('/batches/:id', :action => 'show')
  end

  map.with_options(:controller => 'user_sessions') do |authentication|
    authentication.login('/login', :action => 'new', :conditions => { :method => :get })
    authentication.logout('/logout', :action => 'destroy', :conditions => { :method => :get })
    authentication.new_session('/new_session', :action => 'create', :conditions => { :method => :post })
  end
end
