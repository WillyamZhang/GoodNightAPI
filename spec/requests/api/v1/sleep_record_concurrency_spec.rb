require 'rails_helper'

RSpec.describe 'Sleep Record Concurrent', type: :request do
  let!(:user) { create(:user) }
  let!(:record) { create(:sleep_record, user: user, clock_in: 1.hour.ago, clock_out: nil) }
  let!(:friend1) { create(:user) }
  let!(:friend2) { create(:user) }

  describe "Concurrent Clock-In" do
    it 'handles concurrent clock-in requests safely' do
      threads = []
      response_statuses = []
  
      10.times do
        threads << Thread.new do
          session = ActionDispatch::Integration::Session.new(Rails.application)
          session.post '/api/v1/sleep_records', params: { user_id: user.id }
          response_statuses << session.response.status
        end
      end
  
      threads.each(&:join)

      expect(SleepRecord.where(user_id: user.id).count).to eq(1)
    end
  end

  describe "Concurrent Clock-Out" do
    it 'handles concurrent clock-out requests safely' do
      threads = []
      response_statuses = []
  
      10.times do
        threads << Thread.new do
          session = ActionDispatch::Integration::Session.new(Rails.application)
          session.patch "/api/v1/sleep_records/clock_out", params: { user_id: user.id }
          response_statuses << session.response.status
        end
      end
  
      threads.each(&:join)
  
      record.reload
      expect(record.clock_out).not_to be_nil
      expect(SleepRecord.where(user_id: user.id, clock_out: nil).count).to eq(0)
    end
  end

  describe "Concurrent Fetch of Following Records" do
    before do
      create(:follow, user: user, followed: friend1)
      create(:follow, user: user, followed: friend2)
  
      create(:sleep_record, user: friend1, clock_in: 2.hours.ago, clock_out: 1.hour.ago)
      create(:sleep_record, user: friend2, clock_in: 3.hours.ago, clock_out: 1.hour.ago)
    end
  
    it 'fetches sleep records concurrently without error' do
      threads = []
      response_statuses = []
  
      10.times do
        threads << Thread.new do
          session = ActionDispatch::Integration::Session.new(Rails.application)
          session.get "/api/v1/sleep_records/following_record", params: { user_id: user.id }
          response_statuses << session.response.status
        end
      end
  
      threads.each(&:join)

      expect(response_statuses.all? { |code| code == 200 }).to be true
    end
  end
end
