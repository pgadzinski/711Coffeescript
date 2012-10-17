class Maxscheduler < ActiveRecord::Base

	has_many :users
	has_many :sites
	has_many :usersites
	has_many :jobs
	has_many :attributes
	
end
