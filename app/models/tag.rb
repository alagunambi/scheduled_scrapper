class Tag < ActiveRecord::Base
  has_many :ads
  has_many :schedules
  
  validates_presence_of :title
end
