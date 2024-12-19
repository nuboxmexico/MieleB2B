class SaleChannel < ApplicationRecord
  has_and_belongs_to_many :products
  has_many :codes_per_channels, dependent: :destroy
  has_many :promotional_codes, through: :codes_per_channels
  has_many :discount_sale_channels, dependent: :destroy
  has_many :product_discounts, through: :discount_sale_channels
  has_many :users
  has_many :quotations
  has_many :banners
end
