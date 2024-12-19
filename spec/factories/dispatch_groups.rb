FactoryBot.define do
  factory :dispatch_group do
    quotation { create(:quotation) }
    state { QuotationState.find_by(name: 'En preparación') || create(:en_preparacion) }

    factory :dispatch_group_in_preparation do 
      state { QuotationState.find_by(name: 'En preparación') || create(:en_preparacion) }
      after(:create) do |dispatch_group|
        products = [
          create(:product_in_dispatch_group, product: create(:product), quantity: 1),
          create(:product_in_dispatch_group, product: create(:product_2), quantity: 2),
          create(:product_in_dispatch_group, product: create(:product_3), quantity: 3)
        ]
        dispatch_group.products_in_dispatch << products
      end
    end

    factory :dispatch_group_dispatched do 
      state { QuotationState.find_by(name: 'Despachado') || create(:despachado) }
    end

    factory :dispatch_group_to_install do 
      state { QuotationState.find_by(name: 'Por instalar') || create(:por_instalar) }
    end

    factory :dispatch_group_installed do 
      state { QuotationState.find_by(name: 'Instalado') || create(:instalado) }
    end

    factory :dispatch_group_pending_installation do 
      state { QuotationState.find_by(name: 'Instalación Pendiente') || create(:instalacion_pendiente) }
    end
  end
end
