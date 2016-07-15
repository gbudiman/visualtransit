class Route < ActiveRecord::Base
  belongs_to :agency
  validates :agency, presence: true

  has_many :directions
  has_many :paths
end
