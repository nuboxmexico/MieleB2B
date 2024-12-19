class CartItem < ApplicationRecord
  scope :availables, -> {where(available: true)}
  scope :to_dispatch, -> {where(dispatch: true, available: true)}
  scope :to_install, -> {where(instalation: true, available: true, is_service: false)}
  scope :to_retire, -> {where(dispatch: false, available: true)}
  scope :not_for_commissions, -> {where('is_service is TRUE or profit_center is FALSE')}
  scope :mdas, -> {where(is_pai: false).joins(:product).where(products: {product_type: 'MDA'})}
  scope :sdas, -> {where(is_pai: false).joins(:product).where(products: {product_type: 'SDA'})}
  scope :pais, -> {where(is_pai: true)}
  scope :apply_dispatch, -> {where(available: true, mandatory: false, dispatch: true, is_service: false)}
  
  belongs_to :cart
  belongs_to :product
  belongs_to :product_instalation, class_name: "Instalation", foreign_key: "instalation_id"  

  def sku
    product.sku if product
  end

  def price_eur
    product["price_eur"]
  end

  def price_UF
    unless product["price_eur"]
			return 0
		end
		uf = Indicator.where(name: "uf").take
		euro = Indicator.where(name: "euro").take
		if uf && euro
			return ((euro["value"]/ uf["value"]) * product["price_eur"]).round(2)
		else
			return 0
		end
  end

  def self.uf_to_clp(price_uf)
		unless price_uf
			return 0
		end
		uf = Indicator.where(name: "uf").take
		price_uf * uf["value"]
	end

  def minus_product_to_cart
    self.quantity > 1 && CartItem.update_counters(self, quantity: -1) == 1
  end

  def plus_product_to_cart
    CartItem.update_counters(self, quantity: 1) == 1
  end
end
