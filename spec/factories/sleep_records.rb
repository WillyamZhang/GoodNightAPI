FactoryBot.define do
  factory :sleep_record do
    user
    clock_in { 8.hours.ago }
    clock_out { Time.current }
  end
end
