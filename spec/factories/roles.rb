FactoryBot.define do
  factory :role do
    # Rol Administrador
    name {"Administrador"}

    factory :seller_role do 
    	name {'Seller'}
    end

    factory :finance_role do 
    	name {'Finanzas'}
    end

    factory :manager_role do 
        name {'Manager'}
    end

    factory :foreign_role do
        name {'Consultivo'}
    end

    factory :finance_manager_role do
        name {'Manager Finanzas'}
    end

    factory :dispatch_role do 
        name {'Despacho'}
    end

    factory :dispatch_manager_role do
        name {'Manager Despacho'}
    end

    factory :instalation_role do
        name {'Instalación'}
    end

    factory :instalation_manager_role do
        name {'Manager Instalación'}
    end
  end
end
