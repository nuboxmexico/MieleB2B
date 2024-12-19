FactoryBot.define do
  factory :payment do
    description { "MyString" }
    ammount { 1 }
    pay_date { "2020-03-18 15:46:34" }
    verified { false }
    tbk_transaction_id { "MyString" }
    tbk_token { "MyString" }
    state { "MyString" }
    webpay_data { "MyString" }
    quotation { nil }

    factory :cash_payment do 
        pay_date {DateTime.now}
        ammount {699990}
        payment_type {'efectivo'}
        state {'complete'}
    end
  end
end
