class Schedule < ActiveRecord::Base
  belongs_to :tag
  validates_presence_of :date, :tag_id
end
