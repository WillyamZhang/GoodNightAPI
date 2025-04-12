require 'rails_helper'

RSpec.describe 'Concurrent Follow Requests', type: :request do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }

  it 'handles concurrent follow requests correctly' do
    threads = []
    response_statuses = []

    10.times do
      threads << Thread.new do
        session = ActionDispatch::Integration::Session.new(Rails.application)
        session.post "/api/v1/follows", params: { user_id: user_a.id, followed_id: user_b.id }
        response_statuses << session.response.status
      end
    end

    threads.each(&:join)

    expect(response_statuses.count(201)).to eq(1)
    expect(Follow.where(user_id: user_a.id, followed_id: user_b.id).count).to eq(1)
  end

  it 'handles concurrent unfollow requests correctly' do
    create(:follow, user: user_a, followed: user_b)

    threads = []
    response_statuses = []

    10.times do
      threads << Thread.new do
        session = ActionDispatch::Integration::Session.new(Rails.application)
        session.delete "/api/v1/follows/unfollow", params: { user_id: user_a.id, followed_id: user_b.id }
        response_statuses << session.response.status
      end
    end

    threads.each(&:join)

    expect(response_statuses.count(200)).to eq(1)
    expect(Follow.where(user_id: user_a.id, followed_id: user_b.id)).to be_empty
  end
end
