class CreateFollows < ActiveRecord::Migration[8.0]
  def self.up
    create_table :follows do |t|
      t.references :user
      t.integer :followed_id
      t.timestamps
    end
  end

  def self.down
    drop_table :follows
  end
end
