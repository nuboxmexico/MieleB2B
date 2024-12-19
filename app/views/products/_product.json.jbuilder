json.extract! product, :id, :name, :sku, :price_formatted
json.url product_url(product, format: :json)
json.set! :image_url, product.get_product_photo('search')
json.set! :discount, product.display_price(current_user)[0]
json.set! :discount_price, number_to_currency(product.display_price(current_user)[1])