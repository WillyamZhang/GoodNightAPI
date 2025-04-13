# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

#User.destroy_all
#User.create!([
#  { name: "user1" },
#  { name: "user2" },
#  { name: "user3" },
#  { name: "user4" },
#  { name: "user5" }
#])

require 'faker'

puts "Cleaning database..."
Follow.delete_all
SleepRecord.delete_all
User.delete_all

ActiveRecord::Base.logger.silence do
  # Seed Users
  puts "Seeding 50,000 users..."
  users = Array.new(50_000) do
    {
      name: Faker::Name.name,
      created_at: Time.now,
      updated_at: Time.now
    }
  end
  User.insert_all(users)
  user_ids = User.pluck(:id)

  # Seed SleepRecords (3–5 per user)
  puts "Seeding sleep records (3–5 per user)..."
  sleep_records = []
  user_ids.each do |user_id|
    rand(3..5).times do
      clock_in = rand(10..30).days.ago
      clock_out = clock_in + rand(4..10).hours
      sleep_records << {
        user_id: user_id,
        clock_in: clock_in,
        clock_out: clock_out,
        created_at: Time.now,
        updated_at: Time.now
      }
    end
  end
  SleepRecord.insert_all(sleep_records)
  puts "Total sleep records inserted: #{sleep_records.size}"

  # Seed Follows (up to 10 per user)
  puts "Seeding follow relationships..."
  follows = []
  user_ids.each do |user_id|
    followed_ids = user_ids.sample(rand(2..10)).uniq - [user_id]
    followed_ids.each do |followed_id|
      follows << {
        user_id: user_id,
        followed_id: followed_id,
        created_at: Time.now,
        updated_at: Time.now
      }
    end
  end
  Follow.insert_all(follows)
end

puts "Seeding complete!"

