class CreateJobLoggings < ActiveRecord::Migration
  def change
    create_table :job_loggings do |t|
      t.string :job_id
      t.string :user_id
      t.string :maxscheduler_id
      t.text :jobDetailsBefore
      t.text :jobDetailsAfter
      t.text :jobDetailsChange

      t.timestamps
    end
  end
end
