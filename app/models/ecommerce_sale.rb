class EcommerceSale < ApplicationRecord
	belongs_to :commune
	has_many :quotation_products, dependent: :destroy
	has_many :products, through: :quotation_products

	def self.discount_stock(product)
		if (product_t = Product.find_by(sku: product[:tnr]))
			product_t.with_lock do
				product_t.stock = (product_t.stock - product[:quantity].to_i)
				product_t.save
			end
			product_t.check_linked_quotations
		end
	end

	def self.reverse_stock(product)
		if (product_t = Product.find_by(sku: product[:tnr]))
			product_t.with_lock do
				product_t.stock = (product_t.stock + product[:quantity].to_i)
				product_t.save
			end
		end
	end
end
