FactoryBot.define do
  factory :cart do
    # Carrito administrador
    # id   {1}
    user {User.find_by(name: 'Administrador') || create(:user)}
    apply_discount {true}

    factory :cart_with_product do
    	after(:create) do |cart|
    		CartItem.create(cart: cart, product: (Product.last || create(:product)), quantity: 1, price: 699990)
            Quotation.define_discount(Cart.last.cart_items, Cart.last.promotional_code, true)
    	end
    end

    factory :cart_with_product_next_level do
    	after(:create) do |cart|
    		CartItem.create(cart: cart, product: (Product.last || create(:product)), quantity: 11, price: 699990)
            Quotation.define_discount(Cart.last.cart_items, Cart.last.promotional_code, true)
    	end
    end

    factory :cart_in_last_level do
        after(:create) do |cart|
            CartItem.create(cart: cart, product: (Product.last || create(:product)), quantity: 46, price: 699990)
            Quotation.define_discount(Cart.last.cart_items, Cart.last.promotional_code, true)
        end
    end

    factory :cart_with_service do
        after(:create) do |cart|
            CartItem.create(cart: cart, product: (Product.last || create(:product)), quantity: 1, price: 699990)
            CartItem.create(cart: cart, product: (create(:product_service) || association(:product_service)), quantity: 1, price: 29900)
            Quotation.define_discount(Cart.last.cart_items, Cart.last.promotional_code, true)
        end
    end
  end
end
