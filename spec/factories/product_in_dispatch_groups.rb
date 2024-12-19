FactoryBot.define do
  factory :product_in_dispatch_group do
    dispatch_group { nil }
    product { nil }
    quantity { 1 }
  end
end
