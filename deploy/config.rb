set :application, "Cluster View"
set :repository, 'http://github.com/sanger/cluster_view.git'
#set :repository,  "ssh://git.internal.sanger.ac.uk/repos/git/psd/api.git"

# Use the badger user
#set :user, "badger"
#set :group, "w3adm"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

set :keep_releases, 4

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
set :branch, "master"

after('deploy:update') do 
  run "ln -sf #{ shared_path }/app-config/database.yml #{ current_path }/config/database.yml"
end

