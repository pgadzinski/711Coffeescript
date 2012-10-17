class Site < ActiveRecord::Base

	belongs_to :maxscheduler
	has_many :resources
	has_many :users, :through => :usersites
	has_many :usersites
	has_many :operationhours
	has_many :jobs

end
