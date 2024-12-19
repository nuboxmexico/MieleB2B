FactoryBot.define do
  factory :quotation do
    # Cotización administrador
    user {User.find_by(name: 'Administrador') || create(:user)}
    name {'Usuario'}
    lastname {'prueba'}
    second_lastname {'materno'}
    rut {'11111111-1'}
    email {'hola@prueba.net'}
    phone {987654321}
    dispatch_address {'Calle falsa'}
    dispatch_address_number {'123'}
    dispatch_dpto_number {'1116'}
    dispatch_commune {Commune.find_by(name: 'Santiago') || create(:santiago)}
    personal_address {'Calle verdadera'}
    personal_address_number {'456'}
    personal_dpto_number {'982'}
    personal_commune {Commune.find_by(name: 'Providencia') || create(:providencia)}
    instalation_address {'Calle ultra falsa'}
    instalation_address_number {'789'}
    instalation_dpto_number {'012'}
    instalation_commune {Commune.find_by(name: 'Recoleta') || create(:recoleta)}
    estimated_dispatch_date {Date.parse('20/12/2020', "%d/%m/%Y")}
    installation_date {Date.parse('30/12/2020', "%d/%m/%Y")}
    cost_center {CostCenter.first || create(:cost_center)}
    observations {'Solo PM'}
    quotation_state {QuotationState.find_by(name: 'Enviada') || create(:enviada)}
    document_type {'Boleta'}
    apply_discount {true}
    currency {:clp}
    customer { Customer.first || create(:customer) }

    after(:create) do |quotation|
      quotation.update(total: quotation.total_calc)
      Quotation.define_discount(Quotation.first.quotation_products, Quotation.first.promotional_code, true)
    end

    factory :quotation_retirement do 
      after(:create) do |quotation|
         create(:quotation_product, quotation: quotation)
         Quotation.define_discount(Quotation.first.quotation_products, Quotation.first.promotional_code, true)
         quotation.update(total: quotation.total_calc)
     end
   end

   factory :quotation_dispatch do 
      after(:create) do |quotation|
        create(:quotation_product, quotation: quotation, dispatch: true)
        Quotation.define_discount(Quotation.first.quotation_products, Quotation.first.promotional_code, true)
        quotation.update(total: quotation.total_calc)
      end
   end
   factory :quotation_dispatch_retirement do 
      after(:create) do |quotation|
        create(:quotation_product, quotation: quotation, quantity: 1, dispatch: true)
        create(:quotation_product, quotation: quotation, quantity: 1, dispatch: false, product: create(:product_3))
        Quotation.define_discount(Quotation.first.quotation_products, Quotation.first.promotional_code, true)
        quotation.set_dispatch_group
        quotation.set_products_in_dispatch_group
        quotation.update(total: quotation.total_calc)
     end
   end

   factory :retail_quotation do 
      id   {1}
      user {User.find_by(email: 'retail@test.net') || create(:retail_user)}
      name {'Retail'}
      lastname {'prueba'}
      second_lastname {'materno'}
      rut {'11.111.111-1'}
      email {'hola@prueba.net'}
      phone {987654321}
      dispatch_address {'Calle falsa 123'}
      dispatch_address_number {nil}
      dispatch_dpto_number {nil}
      dispatch_commune {Commune.last || create(:santiago)}
      personal_address {nil}
      personal_address_number {nil}
      personal_dpto_number {nil}
      personal_commune {nil}
      instalation_address {nil}
      instalation_address_number {nil}
      instalation_dpto_number {nil}
      instalation_commune {nil}
      estimated_dispatch_date {Date.parse('20/12/2020', "%d/%m/%Y")}
      agreed_dispatch_date {Date.parse('01/12/2020', "%d/%m/%Y")}
      installation_date {nil}
      dispatch_city {'Santiago'}
      cost_center {CostCenter.first || create(:cost_center)}
      observations {'Solo PM'}
      quotation_state {QuotationState.find_by(name: 'Ingresada') || create(:ingresada)}
      document_type {nil}
      upc {nil}
      receiver_name {'Mieler'}
      f12_number {'987654321'}
      oc_number {'123456789'}
      retail {Retail.first || create(:falabella)}
      dispatch_value {20000}
      sale_channel {SaleChannel.find_by(name: 'Retail') || create(:retail_sale_channel)}
      currency {:clp}

      after(:create) do |quotation|
          create(:retail_quotation_product, quotation: quotation)
      end
    end

    factory :quotation_with_products do 
      after :create do |quotation|
        create(:quotation_product, quotation: quotation, quantity: 1)
        create(:quotation_product_2, quotation: quotation, quantity: 2)
        create(:quotation_product_3, quotation: quotation, quantity: 3)
      end
    end

    factory :quotation_to_partal_reception do 
      after :create do |quotation|
        quotation_product_1 = create(:quotation_product, quotation: quotation, quantity: 1, activation_ready: true)
        quotation_product_2 = create(:quotation_product_2, quotation: quotation, quantity: 2, activation_ready: true)

        products = [
          create(:product_in_dispatch_group, product: quotation_product_1.product, quantity: 1),
          create(:product_in_dispatch_group, product: quotation_product_2.product, quantity: 0)
        ]
        dispatch_group_1 = create(:dispatch_group)
        dispatch_group_1.products_in_dispatch << products

        quotation.dispatch_groups << dispatch_group_1
      end
    end

    factory :quotation_in_preparation do 
      after :create do |quotation|
        quotation.to_state('En preparación')
        
        create(:quotation_product, quotation: quotation, quantity: 1, activation_ready: true)
        create(:quotation_product_2, quotation: quotation, quantity: 2, activation_ready: true)
        create(:quotation_product_3, quotation: quotation, quantity: 3, activation_ready: true)

        dispatch_group = quotation.dispatch_groups.last
        if dispatch_group
          quotation.quotation_products.each do |item|
            dispatch_group.products_in_dispatch << create(:product_in_dispatch_group,
                                                    product: item.product, 
                                                    quantity: item.quantity)
          end
        end
      end
    end

    factory :quotation_with_dispatched_state do 
      after :create do |quotation|
        quotation.to_state('Despachado')

        create(:quotation_product, quotation: quotation, quantity: 1, activation_ready: true)
        create(:quotation_product_2, quotation: quotation, quantity: 2, activation_ready: true)
        create(:quotation_product_3, quotation: quotation, quantity: 3, activation_ready: true)

        dispatch_group = quotation.set_dispatch_group
        quotation.quotation_products.each do |item|
          dispatch_group.products_in_dispatch << create(:product_in_dispatch_group,
                                                  product: item.product, 
                                                  quantity: item.quantity)
        end
        dispatch_group.to_state('Despachado')
      end
    end

    factory :quotation_with_to_install_state do 
      after :create do |quotation|
        quotation.to_state('Por instalar')

        create(:quotation_product, quotation: quotation, quantity: 1, activation_ready: true)
        create(:quotation_product_2, quotation: quotation, quantity: 2, activation_ready: true)
        create(:quotation_product_3, quotation: quotation, quantity: 3, activation_ready: true)

        dispatch_group = quotation.set_dispatch_group
        quotation.quotation_products.each do |item|
          dispatch_group.products_in_dispatch << create(:product_in_dispatch_group,
                                                  product: item.product, 
                                                  quantity: item.quantity)
        end
        dispatch_group.to_state('Por instalar')
      end
    end

    factory :quotation_for_project do 
      user {User.find_by(email: 'project@test.net') || create(:project_user)}
      name {'Proyectos'}
      lastname {'Manager'}
      second_lastname {'materno'}
      rut {'11.111.111-1'}
      email {'hola@prueba.net'}
      phone {987654321}
      dispatch_address {'Calle despacho'}
      dispatch_address_number {'123'}
      dispatch_commune {Commune.last || create(:santiago)}
      personal_address {'Dirección personal'}
      personal_address_number {'321'}
      personal_commune {Commune.last || create(:santiago)}
      instalation_address {'Lugar de instalación'}
      instalation_address_number {'999'}
      instalation_commune {Commune.last || create(:santiago)}
      estimated_dispatch_date {Date.new(2020, 12, 20)}
      installation_date {Date.new(2020, 12, 01)}
      dispatch_city {'Santiago'}
      cost_center {CostCenter.first || create(:cost_center)}
      observations {'Solo PM'}
      quotation_state {QuotationState.find_by(name: 'En Negociación') || create(:en_negociacion)}
      sale_channel {SaleChannel.find_by(name: 'Proyectos') || create(:project_business_sale_channel)}
      currency {:uf}
      business_sector {'Giro'}

      after(:create) do |quotation|
        create(:quotation_product, quotation: quotation, quantity: 1)
        create(:quotation_product_2, quotation: quotation, quantity: 2)
        create(:quotation_product_3, quotation: quotation, quantity: 3)
        quotation.update(total: quotation.quotation_products.map{|i| i.price * i.quantity}.sum)
      end
    end

    factory :quotation_with_later_versions do 
      user {User.find_by(email: 'project@test.net') || create(:project_user)}
      name {'Proyectos'}
      lastname {'Manager'}
      second_lastname {'materno'}
      rut {'11.111.111-1'}
      email {'hola@prueba.net'}
      phone {987654321}
      dispatch_address {'Calle despacho'}
      dispatch_address_number {'123'}
      dispatch_commune {Commune.last || create(:santiago)}
      personal_address {'Dirección personal'}
      personal_address_number {'321'}
      personal_commune {Commune.last || create(:santiago)}
      instalation_address {'Lugar de instalación'}
      instalation_address_number {'999'}
      instalation_commune {Commune.last || create(:santiago)}
      estimated_dispatch_date {Date.new(2020, 12, 20)}
      installation_date {Date.new(2020, 12, 01)}
      dispatch_city {'Santiago'}
      cost_center {CostCenter.first || create(:cost_center)}
      observations {'Solo PM'}
      quotation_state {QuotationState.find_by(name: 'En Negociación') || create(:en_negociacion)}
      sale_channel {SaleChannel.find_by(name: 'Proyectos') || create(:project_business_sale_channel)}
      
      after :create do |version_1|
        create(:quotation_product, quotation: version_1, quantity: 1)
        create(:quotation_product_2, quotation: version_1, quantity: 2)
        create(:quotation_product_3, quotation: version_1, quantity: 3)
        version_1.update_total
        
        version_2 = version_1.create_new_version
        version_2.quotation_products.last.destroy
        version_2.update_total

        version_3 = version_2.create_new_version
        version_3.quotation_products.last.destroy
        version_3.update_total
      end
    end
  end
end
