FactoryBot.define do
  factory :promotional_code do
    name { "Descuento febrero" }
    code { "30OFF" }
    description { "Para vendedores" }
    use_limit { 1 }
    start_date { "2020-01-31" }
    end_date { "2020-02-28" }
    percent { 30 }
    is_for_product {true}

    factory :unlimited_code do
        use_limit {-1}
    end
end
end
