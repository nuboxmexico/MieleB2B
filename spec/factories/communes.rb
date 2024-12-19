FactoryBot.define do
	factory :commune do
		name { "MyString" }
		region { nil }

		factory :santiago do
			name {'Santiago'}
			region {Region.find_by(name: 'Región Metropolitana') || create(:metropolitana)}
		end

		factory :providencia do
			name {'Providencia'}
			region {Region.find_by(name: 'Región Metropolitana') || create(:metropolitana)}
		end

		factory :recoleta do
			name {'Recoleta'}
			region {Region.find_by(name: 'Región Metropolitana') || create(:metropolitana)}
		end

		factory :valparaiso do 
			name {'Valparaíso'}
			region {Region.find_by(name: 'Región de Valparaíso') || create(:region_valpo)}
		end
	end
end
