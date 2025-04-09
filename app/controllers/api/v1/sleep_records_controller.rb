class Api::V1::SleepRecordsController < ApplicationController

  def create
    record = SleepRecord.new(sleep_record_params)
    record.clock_in = Time.now
    if record.save
      render json: { message: "Clocked In successfully", records: SleepRecord.all_record(record.user_id) }, status: :created
    else
      render json: { error: record.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def sleep_record_params
    params.permit(:user_id)
  end
end
