module ComparatorHelper
	def check_offer_comparator(product)
		if product.display_price(current_user)[0]
			return '<p class="no-bottom"><span class="new-price-comp">'+number_to_currency(product.display_price(current_user)[1])+'</span></p><p><span class="old-comp-price strikediag">'+number_to_currency(product.price_formatted)+'</span></p>'.html_safe
		else
			return '<p class="comp-price">'+product.price_formatted+'</p>'.html_safe
		end
	end
end