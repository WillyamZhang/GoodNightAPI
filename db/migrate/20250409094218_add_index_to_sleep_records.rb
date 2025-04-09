class AddIndexToSleepRecords < ActiveRecord::Migration[8.0]
  def change
    # use composite index for SleepRecord.all_record(record.user_id)
    add_index :sleep_records, [:user_id, :created_at]
  end
end
