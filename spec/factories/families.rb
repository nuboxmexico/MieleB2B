FactoryBot.define do
  factory :family do
    name { "MyString" }

    factory :business_unit do
    	name {'Cocción'}
        depth {0}
    end

    factory :services_family do
        name {'Servicios'}
        depth {0}
    end

    factory :family_1 do
    	name {'Cocina'}
    	family_id {Family.last.id}
        depth {1}
    end

    factory :family_2 do
    	name {'Cafeteras'}
    	family_id {Family.last.id}
        depth {2}
    end

    factory :accesories do
        name {'Accesorios'}
        depth {0}
    end

    factory :washing_machines do
        name {'Lavado'}
        depth {0}
    end

    factory :family_diferent do
        name {'Hornos'}
        family_id {Family.first.id}
        depth {1}
    end

    factory :lavadoras do 
        name {'Lavadoras'}
    end
  end
end
