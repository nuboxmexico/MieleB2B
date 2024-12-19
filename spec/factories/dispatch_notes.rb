FactoryBot.define do
  factory :dispatch_note do
    observation { "MyText" }
    user { nil }
    dispatch_group { nil }
    category { 1 }
  end
end
