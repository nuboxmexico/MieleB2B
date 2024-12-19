FactoryBot.define do
  factory :email_addressee do
    user { nil }
    process { "MyString" }
  end
end
