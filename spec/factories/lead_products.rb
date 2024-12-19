FactoryBot.define do
  factory :lead_product do
    sku { "MyString" }
    name { "MyString" }
    quantity { 1 }
    unit_price { 1 }
    lead { nil }
  end
end
