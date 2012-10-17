class Usersite < ActiveRecord::Base

	belongs_to :maxscheduler
	belongs_to :user
	belongs_to :site

end
