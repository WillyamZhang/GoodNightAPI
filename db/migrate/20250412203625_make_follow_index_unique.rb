class MakeFollowIndexUnique < ActiveRecord::Migration[8.0]
  def change
    remove_index :follows, column: [:user_id, :followed_id]
    add_index :follows, [:user_id, :followed_id], unique: true
  end
end
