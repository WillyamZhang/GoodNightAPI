class Api::V1::SleepRecordsController < ApplicationController
  before_action :set_user_id, only: [:create, :clock_out, :following_record]

  def create
    SleepRecord.transaction do
      all_record = SleepRecord.all_record(@user_id).select("id, user_id, clock_in")
      locked_record = SleepRecord.locked_active_for(@user_id)
      return render_already_clocked_in(all_record) if locked_record

      record = SleepRecord.new(sleep_record_params)
      record.clock_in = Time.current
      if record.save
        render json: { message: "Clocked In successfully", records: all_record }, status: :created
      else
        render json: { error: record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end  

  def clock_out
    SleepRecord.transaction do
      locked_record = SleepRecord.locked_active_for(@user_id)
      return render_sleep_not_found if locked_record.nil?
  
      if locked_record.update(clock_out: Time.current)
        render json: { message: "Clocked Out successfully", records: locked_record }, status: :ok
      else
        render json: { errors: locked_record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def following_record
    user = User.find_by(id: @user_id)
    if user.nil?
      render json: { error: "User not found" }, status: :not_found
      return
    end

    records = SleepRecord.sleep_records_from_following(user.following_ids)

    render json: { following_records: records.map { |r| { result: r.formatted_result } } }, status: :ok
  end

  private

  def sleep_record_params
    params.permit(:user_id)
  end

  def set_user_id
    @user_id = params[:user_id]
  end

  def render_already_clocked_in(records)
    render json: { message: "Already clocked in", records: records }, status: :ok
  end
  
  def render_sleep_not_found
    render json: { error: "Sleep record not found" }, status: :not_found
  end
end
