Factory.define('User: John Smith', :class => User) do |user|
  user.username               'John Smith'
  user.password               'John Smith'
  user.password_confirmation  'John Smith'
end

Factory.define('User: Default login user', :class => User) do |user|
  user.username               'Default login user'
  user.password               'Default login user'
  user.password_confirmation  'Default login user'
end

