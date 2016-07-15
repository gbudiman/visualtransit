class Direction < ActiveRecord::Base
  belongs_to :route
  validates :route, presence: true

  has_many :direction_stops, dependent: :destroy
end
