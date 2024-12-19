module ProductsHelper
	def check_offer(product)
		if product.display_price(current_user)[0]
			return '<p class="no-bottom"><span class="new-price">'+number_to_currency(product.display_price(current_user)[1])+'</span></p><p><span class="old-price strikediag">'+number_to_currency(product.price.round(0))+'</span></p>'.html_safe
		else
			return '<p class="product-card-price">'+product.price_formatted+'</p>'.html_safe
		end
	end

	def check_offer_show(product)
		if product.display_price(current_user)[0]
			return '<p><span class="old-price strikediag">'+number_to_currency(product.price)+'</span> <span class="new-price"> '+number_to_currency(product.display_price(current_user)[1])+'</span></p>'.html_safe
		else
			return '<p class="product-price">'+product.price_formatted+'</p>'.html_safe
		end
	end

	def from_price_bstock(product)
		bstock_cheaper = Product.where(sku: product.sku)
													  .where.not(ean: nil)
													  .order('discount DESC')
													  .first
		if bstock_cheaper
			return '<p class="product-card-price">Desde '+number_to_currency(bstock_cheaper.bstock_price(product))+'</p>'
		else
			return '<p class="product-card-price"></p>'
		end
	end

	def any_bstock(product)
		bstock = Product.where(sku: product.sku)
													  .where.not(ean: nil)
													  .order('discount DESC')
		bstock.any?
	end
end
