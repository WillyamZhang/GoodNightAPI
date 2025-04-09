class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def self.up
    create_table :sleep_records do |t|
      t.references :user
      t.datetime :clock_in
      t.datetime :clock_out
      t.timestamps
    end
  end

  def self.down
    drop_table :sleep_records
  end
end
