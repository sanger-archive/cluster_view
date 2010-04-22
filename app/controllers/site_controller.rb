class SiteController < ApplicationController
  before_filter :require_user, :except => :index

  def index
    # Empty as this simply falls through to the view
  end
end
