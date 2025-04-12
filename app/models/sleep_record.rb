class SleepRecord < ApplicationRecord
  belongs_to :user

  # validate when clock_out value is available
  validate :validate_clocked_out, if: -> { clock_out.present? }

  # Filters records that have both clock_in and clock_out
  scope :with_complete_sleep, -> { where.not(clock_in: nil, clock_out: nil) }

  # Filters records created within the last 7 days
  scope :from_last_week, -> { where('created_at >= ?', 1.week.ago) }

  # Order by sleep duration (clock_out - clock_in)
  scope :order_by_sleep_duration, -> {
    order(Arel.sql("TIMESTAMPDIFF(SECOND, clock_in, clock_out)"))
  }

  # Returns completed sleep records from users the current user follows
  def self.sleep_records_from_following(following_ids)
    where(user_id: following_ids)
      .with_complete_sleep
      .from_last_week
      .includes(:user)
      .order_by_sleep_duration
  end

  # Returns a simple string with sleep duration and user name
  def formatted_result
    "record #{sleep_minutes} minutes from #{user.name}"
  end

  # Returns all sleep records for a given user, ordered by created_at
  def self.all_record(user_id)
    where(user_id: user_id).order("created_at")
  end

  # Returns the currently active sleep record (clock_out is nil) for a given user
  def self.active_for(user_id)
    find_by(user_id: user_id, clock_out: nil)
  end

  private

  # Custom validation to ensure clock_out is after clock_in
  def validate_clocked_out
    if clock_out < clock_in
      errors.add(:clock_out, "Clocked Out datetime must be greater than Clocked In")
    end
  end

  # Calculates sleep duration in minutes; returns 0 if incomplete
  def sleep_minutes
    return 0 unless clock_in && clock_out
    ((clock_out - clock_in) / 60.0).to_i
  end
end
