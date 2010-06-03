class TruncateSessionsTable < ActiveRecord::Migration
  class Session < ActiveRecord::Base
  end

  def self.up
    Session.delete_all
  end

  def self.down
    # Nothing to do
  end
end
