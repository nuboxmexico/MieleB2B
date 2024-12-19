class Cart < ApplicationRecord
  belongs_to :user, -> { with_deleted }
  belongs_to :promotional_code,  class_name: 'PromotionalCode'
  belongs_to :dispatch_code, class_name: 'PromotionalCode'
  has_many   :cart_items   , dependent: :destroy
  has_many   :products     , through: :cart_items 
  belongs_to :quotation

  def clp_to_UF(price_clp)
    unless price_clp
			return 0
		end
		uf = Indicator.where(name: "uf").take
		if uf
			return ((1/ uf["value"]) * price_clp).round(2)
		else
			return 0
		end 
  end
  
  def add_product_to_cart(product, quantity, current_user)
    if item = cart_items.find_by(product: product) and !item.is_service
      CartItem.update_counters(item, quantity: quantity.to_i) == 1  
      self.reload
    else
      CartItem.create(cart: self, 
        product: product,
        quantity: quantity, 
        price: current_user.is_project? ? clp_to_UF(product.display_price(current_user)[1]) : product.display_price(current_user)[1],
        mandatory: product.mandatory, 
        name: product.name,
        instalation: (product.instalation ? true : false), 
        dispatch: (current_user.is_mca? ? true : ((product.dispatch or !product.can_retire) ? true : false)), 
        is_service: product.is_service, 
        order_item: (product.instalations.size > 0 ? (self.cart_items.map(&:order_item).max.to_i + 1) : 0 ), 
        is_pai: (product.product_type == 'PAI'), 
        profit_center: product.profit_center)
      self.reload
    end
  end

  def add_bstock(original, bstock, current_user)
    self.cart_items << CartItem.create(product: bstock, 
      quantity: 1, 
      price: bstock.bstock_price(original), 
      mandatory: false, 
      instalation: (original.instalation ? true : false), 
      dispatch: (current_user.is_mca? ? true : ((original.dispatch or !original.can_retire) ? true : false)), 
      is_service: false, 
      order_item: (self.cart_items.map(&:order_item).max.to_i + 1), 
      name: "#{original.name} - #{bstock.category} - #{bstock.discount}%", 
      is_pai: (original.product_type == 'PAI'), 
      profit_center: bstock.profit_center)
  end

  def clone_products(current_user)
    self.quotation.quotation_products.each do |item|
      item_price = item.product.display_price(current_user)[1]
      if current_user.can_manage_project_quotations? or item.quantity <= item.product.try(:stock).to_i
        quantity_t =  item.quantity 
        item_price = item.price
      else
        quantity_t = item.product.try(:stock).to_i
      end
      if quantity_t > 0
        CartItem.create(cart: self,
          product: item.product,
          quantity: quantity_t,
          price: item_price,
          mandatory: item.mandatory,
          name: item.name,
          instalation: item.instalation,
          dispatch: item.dispatch,
          is_service: item.is_service,
          order_item: item.order_item,
          is_pai: item.is_pai,
          profit_center: item.profit_center,
          instalation_id: item.instalation_id
          )
      end
    end
  end

  def get_dispatch_products
    return  cart_items.map{|item| item if item.dispatch}.compact
  end

  def total_cost
    return cart_items.map{|item| item.quantity * item.price.to_f }.reduce(:+) || 0
  end

  def uf_to_clp(price_uf)
		unless price_uf
			return 0
		end
		uf = Indicator.where(name: "uf").take
		price_uf * uf["value"]
	end

  def self.euro_to_UF(price_eur)
		uf = Indicator.where(name: "uf").take
		euro = Indicator.where(name: "euro").take
		if uf && euro
			return ((euro["value"]/ uf["value"]) * price_eur)
		else
			return 0
		end
	end

  def self.euro_to_clp(price_eur)
		unless price_eur
			return 0
		end
		euro = Indicator.where(name: "euro").take
		price_eur * euro["value"]
	end

  def calculate_margen(cart_item)
    if cart_item
      margen = 0
			product = Product.find(cart_item["product_id"])
			product_price = Cart.euro_to_UF(product["price_eur"].to_f)
			product_cost = Cart.euro_to_UF(product["cost"].to_f)
			if product["price_eur"] && product["cost"]
				margen = (cart_item["quantity"].to_i * cart_item["price"]) - (cart_item["quantity"].to_i * product_cost)
			end
		end
    margen.round(2)
  end


	# 	if cart_item
  #     margen = 0
	# 		product = Product.find(cart_item["product_id"])
      
	# 		if product["cost"]
	# 			if cart_item["is_price_UF"]
	# 				margen = (cart_item["quantity"].to_i*uf_to_clp(cart_item["price"])) - (cart_item["quantity"].to_i*product["cost"].to_f)
	# 			else
	# 				margen = (cart_item["quantity"].to_i*cart_item["price"]) - (cart_item["quantity"].to_i*product["cost"].to_f)
	# 			end
	# 		end
	# 	end
	# 	margen
	# end

  def margen_cost
    sub_total = self.total_cost #uf_to_clp(self.total_cost)
    # price_eur_total = 0
    # self.cart_items.each { |cart_item| price_eur_total = cart_item.quantity * Cart.euro_to_UF(cart_item.product.price_eur) if cart_item.product.cost && cart_item.product.price_eur }
    margen = 0
    cart_items.each do |c|
      margen = margen + calculate_margen(c)
    end
    total_margen_percentage = sub_total > 0 ? (margen / sub_total) * 100 : 0
    total_margen_percentage.round(2)
  end

  def total
    total_before_code - discount_per_code - self.discount_code_dispatch
  end

  def total_before_code
    delta = self.total_cost.to_f
    if !self.bstock
      delta -= (total_section_discount + total_miele_discount)
    end
    delta += self.dispatch_value
    delta += self.installation_value
    delta
  end

  def total_section_discount
    discount = 0
    cart_items.where(discount_type: 'section').map{|item| discount += (item.quantity * item.discount)}
    discount
  end

  def total_miele_discount
    discount = 0
    cart_items.where(discount_type: 'miele').map{|item| discount += (item.quantity * item.discount)}
    discount
  end

  def discount_per_code
    discount = 0
    cart_items.where(discount_type: 'code').map{|item| discount += (item.quantity * item.discount)}
    discount
  end

  def discount_code_dispatch
    if self.dispatch_code
      self.dispatch_value * (self.dispatch_code.percent.to_f / 100 )
    else
      0
    end
  end

  def total_per_pay
    if self.pay_percent == 100
      self.total
    else
      self.total * self.pay_percent / 100 + self.inmediatly_paid
    end
  end

  def inmediatly_paid
    for_pay_now = 0
    self.cart_items.to_retire.each do |item| 
      for_pay_now += ((item.price * item.quantity) - (item.discount * item.quantity))
    end
    return (for_pay_now/2)
  end

  def clean
    cart_items.destroy_all
    self.update!(pay_percent: 100, quotation_id: nil, promotional_code_id:nil)
  end

  def reset_with_new_products(quotation, user)
    # limpio el carro
    self.clean
    #enlazo la cotizacion y copio algunos datos
    self.update(quotation: quotation, 
                bstock: quotation.bstock, 
                dispatch_value: 0, 
                apply_discount: quotation.apply_discount)
    # copio los items
    self.clone_products(user)
  end
end
