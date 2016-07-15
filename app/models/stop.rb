class Stop < ActiveRecord::Base
  has_many :direction_stop, dependent: :destroy
end
