class Resource < ActiveRecord::Base

  belongs_to :maxscheduler
  belongs_to :board
  belongs_to :user
  belongs_to :site
  
end
