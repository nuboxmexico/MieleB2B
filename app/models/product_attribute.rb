class ProductAttribute < ApplicationRecord
  belongs_to :product
  belongs_to :comparable_attribute
end
