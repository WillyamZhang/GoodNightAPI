class Api::V1::FollowsController < ApplicationController
  before_action :find_unfollow_record, only: [:unfollow]

  def create
    follow = Follow.new(follow_params)

    if follow.save
      render json: { message: "Follow successfully", followed: follow }, status: :created
    else
      render json: { error: record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def unfollow
    if @unfollow_record.nil?
      render json: { error: 'record not found' }, status: :not_found
      return
    end

    if @unfollow_record.destroy
      render json: { message: "UnFollow successfully", Unfollow: @unfollow_record }, status: :ok
    else
      render json: { error: @unfollow_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def follow_params
    params.permit(:user_id, :followed_id)
  end

  def find_unfollow_record
    @unfollow_record = Follow.find_by(follow_params)
  end
end
