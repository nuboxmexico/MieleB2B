class Instalation < ApplicationRecord
	belongs_to :product
	has_many :mandatory_products, dependent: :destroy
	has_many :products, through: :mandatory_products
	has_many :cart_items, dependent: :nullify
end
