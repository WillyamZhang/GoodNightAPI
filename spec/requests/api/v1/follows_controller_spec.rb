require 'rails_helper'

RSpec.describe "Api::V1::FollowsController", type: :request do
  let(:user) { create(:user) }
  let(:followed) { create(:user) }

  describe "POST /api/v1/follows" do
    it "creates a follow record" do
      post "/api/v1/follows", params: { user_id: user.id, followed_id: followed.id }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["message"]).to eq("Follow successfully")
    end
  end

  describe "DELETE /api/v1/follows/unfollow" do
    before { create(:follow, user: user, followed: followed) }

    it "deletes the follow record" do
      delete "/api/v1/follows/unfollow", params: { user_id: user.id, followed_id: followed.id }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("UnFollow successfully")
    end
  end
end
