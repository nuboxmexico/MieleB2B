FactoryBot.define do
  factory :miele_role do
    code { "618" }
    name { "Miele Test" }
    classification { 'A' }

    factory :test_miele_role do 
    	code {'400'}
    	name {'MK prueba'}
    	classification {'B'}
    end

    factory :test_2_miele_role do 
    	code {'500'}
    	name {'Tienda viva'}
    	classification {'C'}
    end

    factory :test_3_miele_role do 
        code {'404'}
        name {'Vivo chicureo'}
        classification {'B'}
    end
  end
end
