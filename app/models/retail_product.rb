class RetailProduct < ApplicationRecord
  belongs_to :product
  belongs_to :retail
end
