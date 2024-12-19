FactoryBot.define do
  factory :dispatch_guide do
    quotation { create(:quotation) }
  end
end
