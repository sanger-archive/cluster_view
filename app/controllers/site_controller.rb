# A very simple controller just to provide some basic site pages.
class SiteController < ApplicationController
  before_filter :require_user, :except => [ :index, :about, :feedback ]

  def index
    # Empty as this simply falls through to the view
  end

  def about
    # Empty as this simply falls through to the view
  end

  def feedback
    # Empty as this simple falls through to the view
  end
end
