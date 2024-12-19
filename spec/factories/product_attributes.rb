FactoryBot.define do
  factory :product_attribute do
    product { nil }
    comparable_attribute { nil }
    value { "MyString" }
  end
end
