class ProductInDispatchGroup < ApplicationRecord
  belongs_to :dispatch_group
  belongs_to :product
end
