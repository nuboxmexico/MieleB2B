FactoryBot.define do
  factory :quotation_note do
    observation { "MyText" }
    user { nil }
    quotation { nil }
  end
end
