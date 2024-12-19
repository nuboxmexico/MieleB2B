class Region < ApplicationRecord
  has_many :communes, dependent: :destroy
end
