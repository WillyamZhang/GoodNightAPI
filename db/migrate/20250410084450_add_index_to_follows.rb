class AddIndexToFollows < ActiveRecord::Migration[8.0]
  def change
    add_index :follows, [:user_id, :followed_id]
  end
end
