class ProductFamily < ApplicationRecord
  belongs_to :product
  belongs_to :family
end
