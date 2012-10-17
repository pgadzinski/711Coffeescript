class Board < ActiveRecord::Base

  belongs_to :maxscheduler
  belongs_to :user
  belongs_to :site

  has_many :resources

end
