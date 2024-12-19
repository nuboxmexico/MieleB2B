FactoryBot.define do
  factory :ecommerce_product do
    ecommerce_sale { nil }
    product { nil }
    quantity { 1 }
    total { 1 }
  end
end
