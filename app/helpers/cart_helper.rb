module CartHelper
	def cart_offer_price(item)
		product = item.product
		if product.display_price(current_user)[0]
			return "<p class='no-bottom'><span class='new-price pt14-cart no-bottom currency-change' data-currency='$'>#{number_with_delimiter(product.display_price(current_user)[1].round(0).to_i )}</span>
                   </p><p><span class='old-price strikediag currency-change' data-currency='$'>#{number_with_delimiter(product.price.round(0))}</span></p>".html_safe
		else
			return "<span class='currency-change' data-currency='$'>#{product.price_formatted}</span>".html_safe 
		end
	end

	def alert_card(item)
		parent = item.cart.cart_items.find_by(order_item: item.order_item, mandatory: false)
		if parent and parent.product_instalation and (parent.product_instalation.products.size == item.cart.cart_items.where(product: parent.product_instalation.products).size)
			return 'linked-alert'.html_safe
		elsif item.product.instalations.size > 0
			return 'mandatory-alert'.html_safe
		else 
			return 'normal-alert'.html_safe
		end
	end

	def bstock_offer_price(item)
		original = Product.find_by(sku: item.product.sku, ean: nil)
		return "<p class='no-bottom'><span class='new-price pt14-cart no-bottom currency-change' data-currency='$'>#{number_with_delimiter(item.price.round(0))}</span>
                   </p><p><span class='old-price strikediag currency-change' data-currency='$'>#{number_with_delimiter(original.price.round(0))}</span></p>".html_safe
	end

	def self.bstock_offer_price_UF(item)
		original = Product.find_by(sku: item.product.sku, ean: nil)
		return "<p class='no-bottom'><span class='new-price pt14-cart no-bottom currency-change' data-currency='$'>#{number_with_delimiter(item.price)}</span>
                   </p><p><span class='old-price strikediag currency-change' data-currency='$'>#{number_with_delimiter(clp_to_UF(original.price))}</span></p>".html_safe
	end

	def self.clp_to_UF(price_clp)
		unless price_clp
			return 0
		end
		uf = Indicator.where(name: "uf").take
		if uf
			return ((1/ uf["value"]) * price_clp)
		else
			return 0
		end
	end

	def self.euro_to_UF(price_eur)
		unless price_eur
			return 0
		end
		uf = Indicator.where(name: "uf").take
		euro = Indicator.where(name: "euro").take
		if uf && euro
			return ((euro["value"]/ uf["value"]) * price_eur)
		else
			return 0
		end
	end

	def euro_to_UF(price_eur)
		unless price_eur
			return 0
		end
		uf = Indicator.where(name: "uf").take
		euro = Indicator.where(name: "euro").take
		if uf && euro
			return ((euro["value"]/ uf["value"]) * price_eur)
		else
			return 0
		end
	end

	def uf_to_clp(price_uf)
		unless price_uf
			return 0
		end
		uf = Indicator.where(name: "uf").take
		price_uf * uf["value"]
	end

	def euro_to_clp(price_eur)
		unless price_eur
			return 0
		end
		euro = Indicator.where(name: "euro").take
		price_eur * euro["value"]
	end

	def calculate_margen(cart_item_id)
		cart_item = CartItem.find(cart_item_id)
		margen_percentage = 0
		if cart_item
			product = Product.find(cart_item["product_id"])
			product_price = euro_to_UF(product["price_eur"].to_f)
			product_cost = euro_to_UF(product["cost"].to_f)
			if product["price_eur"] && product["cost"]
				margen = (cart_item["quantity"].to_i * cart_item["price"]) - (cart_item["quantity"].to_i * product_cost)
				margen_percentage = (margen / (cart_item["quantity"].to_i * cart_item["price"])) * 100
			end
		end
		margen_percentage.round(2)
	end
end
