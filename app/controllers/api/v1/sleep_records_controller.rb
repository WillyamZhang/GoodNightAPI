class Api::V1::SleepRecordsController < ApplicationController
  before_action :find_latest_by_user, only: [:clock_out, :create]

  def create
    record = @latest_record || SleepRecord.new(sleep_record_params)
    record.clock_in = Time.current
    if record.save
      all_record = SleepRecord.all_record(record.user_id).select("id, user_id, clock_in")
      render json: { message: "Clocked In successfully", records: all_record }, status: :created
    else
      render json: { error: record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def clock_out
    if @latest_record.nil?
      render json: { error: 'Sleep record not found' }, status: :not_found
      return
    end

    if @latest_record.update(clock_out: Time.current)
      render json: { message: "Clocked Out successfully", records: @latest_record }, status: :ok
    else
      render json: { errors: @latest_record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def sleep_record_params
    params.permit(:user_id)
  end

  def find_latest_by_user
    @latest_record = SleepRecord.active_for(params[:user_id])
  end
end
