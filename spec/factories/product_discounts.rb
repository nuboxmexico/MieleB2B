FactoryBot.define do
  factory :product_discount do
    discount { 20 }
    start_date { "2020-02-10" }
    end_date { "2020-04-20" }
    product {Product.last || create(:product_with_families)}
  end
end
