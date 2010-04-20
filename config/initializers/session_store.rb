# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cluster_view_session',
  :secret      => 'd473e991eeac9550add8f1005bb8b1aec571e766c022e6ba135ec76447d51203feafbf411ad800e608c4664abe531a91d28529ff18e471a266776d8e83df6137'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
