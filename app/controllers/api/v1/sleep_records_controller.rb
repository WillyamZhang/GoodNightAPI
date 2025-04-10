class Api::V1::SleepRecordsController < ApplicationController
  before_action :find_latest_by_user, only: [:update]

  def create
    record = SleepRecord.new(sleep_record_params)
    record.clock_in = Time.now
    if record.save
      render json: { message: "Clocked In successfully", records: SleepRecord.all_record(record.user_id) }, status: :created
    else
      render json: { error: record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @latest_record.nil?
      render json: { error: 'Sleep record not found' }, status: :not_found
      return
    end

    if @latest_record.update(clock_out: Time.now)
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
    # passing user_id as params[:id]
    @latest_record = SleepRecord.find_by("user_id = ? and clock_out is null", params[:id])
  end
end
