class Api::V1::FollowsController < ApplicationController

  def create
    Follow.transaction do
      locked_record = Follow.locked_record(follow_params)
      return render_already_follow(locked_record) if locked_record

      follow = Follow.new(follow_params)

      if follow.save
        render json: { message: "Follow successfully", followed: follow }, status: :created
      else
        render json: { error: follow.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def unfollow
    Follow.transaction do
      locked_record = Follow.locked_record(follow_params)
      return render_record_not_found if locked_record.nil?
  
      if locked_record.destroy
        render json: { message: "Unfollowed successfully", unfollowed: locked_record }, status: :ok
      else
        render json: { error: locked_record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  private

  def follow_params
    params.permit(:user_id, :followed_id)
  end

  def render_already_follow(records)
    render json: { message: "Already followed", followed: records }, status: :ok
  end

  def render_record_not_found
    render json: { error: 'record not found' }, status: :not_found
  end
end
