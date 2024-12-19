FactoryBot.define do
  factory :quotation_state do
    name { "Test" }

    factory :enviada do
    	name {"Enviada"}
    end

    factory :en_curso do
    	name {"En curso"}
    end

    factory :pendiente do
    	name {"Pendiente"}
    end

    factory :en_preparacion do
    	name {"En preparación"}
    end

    factory :cerrado do
    	name {"Cerrado"}
    end

    factory :vencida do
    	name {"Vencida"}
    end

    factory :despachado do
        name {'Despachado'}
    end

    factory :entregado do
        name {'Entregado'}
    end

    factory :por_instalar do 
        name {'Por instalar'}
    end

    factory :entrega_pendiente do
        name {'Entrega Pendiente'}
    end

    factory :instalado do 
        name {'Instalado'}
    end

    factory :instalacion_pendiente do
        name {'Instalación Pendiente'}
    end

    factory :por_activar do 
        name {'Por activar'}
    end

    factory :productos_activados do 
        name {'Productos activados'}
    end

    factory :ingresada do
        name {'Ingresada'}
    end

    factory :cancelada do
        name {'Cancelada'}
    end

    factory :en_negociacion do
        name {'En Negociación'}
    end

    factory :lead_state do
        name {'Lead'}
    end

    factory :dispatch_to_validate_state do 
        name {'Envíos por validar'}
    end

    factory :dispatch_and_installations_state do 
        name {'Despachos e Instalaciones'}
    end
  end
end
