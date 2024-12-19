FactoryBot.define do
  factory :sale_channel do
    # Sale Channel MCA
    id   {1}
    name {"MCA"}
    color {'#F59B00'}

    factory :sale_channel_with_product do
      after(:create) do |sale_channel|
        sale_channel.products << create(:product)
      end
    end
    # Sale Channel Project Business
    factory :project_business_sale_channel do 
      id   {2}
      name {"Proyectos"}
    end
    # Sale Channel Own Retail
    factory :own_retail_sale_channel do 
      id   {3}
      name {"Own Retail"}
      color {'#8C0314'}
    end
    # Sale Channel Retail
    factory :retail_sale_channel do 
      id   {4}
      name {"Retail"}
      color {'#FD9184'}
    end
    # Sale Channel E-commerce
    factory :ecommerce_sale_channel do 
      id   {5}
      name {"E-commerce"}
      color {'#D5423D'}
    end
  end
end
