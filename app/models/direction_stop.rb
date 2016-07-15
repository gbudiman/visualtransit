class DirectionStop < ActiveRecord::Base
  belongs_to :direction
  validates :direction, presence: true

  belongs_to :stop
  validates :stop, presence: true
end
