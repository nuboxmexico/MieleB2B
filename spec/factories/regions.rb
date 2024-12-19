FactoryBot.define do
  factory :region do
    name { "MyString" }

    factory :metropolitana do
    	id {13}
    	name {'Región Metropolitana'}
    end

    factory :region_valpo do 
    	id {5}
    	name {'Región de Valparaíso'}
    end
  end
end
