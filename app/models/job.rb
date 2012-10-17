class Job < ActiveRecord::Base

	belongs_to :maxscheduler
	belongs_to :user
	belongs_to :site
	belongs_to :resource

end
