FactoryBot.define do
  factory :cart_item do
    # Item en el carrito 1
    id       {1}
    cart     {Cart.find_by(id: 1)              || create(:cart)}
    product  {Product.find_by(sku: "105RR590") || create(:product)}
    quantity {5}
    price {699990}
    discount {false}
    # Item en el carrito 2
    factory :cart_item_2 do
      id       {2}
      cart     {Cart.find_by(id: 1)              || create(:cart)}
      product  {Product.find_by(sku: "10545430") || create(:product_2)}
      quantity {3}
      price {1449990}
      discount {false}
    end
    # Item en el carrito 3
    factory :cart_item_3 do
      id       {3}
      cart     {Cart.find_by(id: 1)              || create(:cart)}
      product  {Product.find_by(sku: "435F3490") || create(:product_3)}
      quantity {4}
      price {999990}
      discount {false}
    end
  end
end
