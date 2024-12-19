FactoryBot.define do
  factory :ecommerce_sale do
    selled_at { DateTime.now }
    commune { Commune.first }
    total { 10000 }
  end
end
