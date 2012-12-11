class User < ActiveRecord::Base

	attr_accessible :FirstName, :LastName, :email, :color, :rowHeight, :password, :password_confirmation, :maxscheduler_id, :currentSite, :currentBoard, :schedStartDate, :timeZone
	has_secure_password

	belongs_to :maxscheduler
	has_many :sites, :through => :usersites
	has_many :usersites
	has_many :jobs

	before_save { |user| user.email = email.downcase }
  	before_save :create_remember_token

	validates :FirstName, presence: true, length: { maximum: 50 }
	validates :LastName, presence: true, length: { maximum: 50 }

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, 
			format: { with: VALID_EMAIL_REGEX },  
			length: { maximum: 100 }, 
			uniqueness: { case_sensitive: false }

	validates :password, presence: true, length: { minimum: 6 }
	validates :password_confirmation, presence: true

	private

    	 def create_remember_token
      		self.remember_token = SecureRandom.urlsafe_base64
    	 end

end
