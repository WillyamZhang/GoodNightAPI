require 'rails_helper'

RSpec.describe "Api::V1::SleepRecordsController", type: :request do
  let(:user) { create(:user) }

  describe "POST /api/v1/sleep_records" do
    it "creates a sleep record and clocks in" do
      post "/api/v1/sleep_records", params: { user_id: user.id }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["message"]).to eq("Clocked In successfully")
    end
  end

  describe "PATCH /api/v1/sleep_records/clock_out" do
    it "clocks out the latest sleep record" do
      create(:sleep_record, user: user, clock_out: nil)

      patch "/api/v1/sleep_records/clock_out", params: { user_id: user.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Clocked Out successfully")
    end
  end

  describe "GET /api/v1/sleep_records/following_record" do
    it "returns sleep records of followed users" do
      followed = create(:user)
      create(:follow, user: user, followed: followed)
      create(:sleep_record, user: followed)

      get "/api/v1/sleep_records/following_record", params: { user_id: user.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key("following_records")
    end
  end
end
