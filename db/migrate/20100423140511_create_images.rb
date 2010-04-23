class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :filename
      t.integer :batch_id

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
