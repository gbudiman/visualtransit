class Agency < ActiveRecord::Base
  has_many :routes, dependent: :destroy
end
