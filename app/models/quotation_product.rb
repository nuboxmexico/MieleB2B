class QuotationProduct < ApplicationRecord
	scope :availables, -> {where(available: true)}
	scope :to_dispatch, -> {where(dispatch: true, available: true)}
	scope :to_install, -> {where(instalation: true, available: true, is_service: false)}
	scope :to_retire, -> {where(dispatch: false, available: true)}
	scope :not_for_commissions, -> {where('is_service is TRUE or profit_center is FALSE')}
	scope :for_commissions, -> {where.not('is_service is TRUE or profit_center is FALSE or is_pai is TRUE')}
	scope :mdas, -> {where(is_pai: false).joins(:product).where(products: {product_type: 'MDA'})}
	scope :sdas, -> {where(is_pai: false).joins(:product).where(products: {product_type: 'SDA'})}
	scope :pais, -> {where(is_pai: true)}
	scope :apply_dispatch, -> {where(available: true, mandatory: false, dispatch: true, is_service: false)}
	scope :quantity_greater_than_zero, -> {where('quantity > 0')}
	scope :quantity_equal_to_zero, -> {where(quantity: 0)}
	
	has_many :detail_quotation_products, dependent: :destroy
	belongs_to :quotation
	belongs_to :product, -> { with_deleted }
	belongs_to :ecommerce_sale
	belongs_to :product_instalation, class_name: "Instalation", foreign_key: "instalation_id" 
	has_many :product_in_unit_real_states, dependent: :destroy

	def remove_quantity(quantity)
		self.update(quantity: [0, self.quantity - quantity].max)
		#restore stock
		if (self.quantity - quantity) >= 0
			self.product.update(stock: self.product.stock + quantity)
		end

    self.update(activation_ready: false) if self.quantity == 0
	end

	def show_as_checked?
		return true if self.quotation.channel == 'Proyectos'
		return (self.activation_ready and self.available)
	end

	def total_price
    	return self.price.to_f * self.quantity.to_i
  	end
end
