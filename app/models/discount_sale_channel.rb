class DiscountSaleChannel < ApplicationRecord
  belongs_to :product_discount
  belongs_to :sale_channel
end
