class AddScheduleTimeStampToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :scheduleTimeStamp, :string

  end
end
