class Path < ActiveRecord::Base
  belongs_to :route
  validates :route, presence: true
end
