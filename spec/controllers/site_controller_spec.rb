require 'spec_helper'

describe SiteController do
  it_should_fall_through_the_following_actions(:index, :about, :feedback)
end
