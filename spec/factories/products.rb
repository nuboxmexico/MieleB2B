FactoryBot.define do
  factory :product do
    # Producto 1
    name  {"Máquina de Café CM5300"}
    ean {nil}
    price {699990}
    sku   {"105RR590"}
    description {"Máquina para el hogar"}
    mandatory {false}
    dispatch {true}
    can_retire {true}
    product_type {'SDA'}
    stock {30}
    stock_break {true}
    outlet{false}

    factory :product_with_families do
      after(:create) do |product|
        product.families << create(:business_unit)
        product.families << create(:family_1)
        product.families << create(:family_2)

      end
    end

    factory :product_comparable_1 do 
      after(:create) do |product|
        product.families << (Family.find_by(name: 'Cocción') || create(:business_unit))
        product.families << (Family.find_by(name: 'Cocina') || create(:family_1))
        create(:product_attribute, comparable_attribute: create(:comparable_attribute), product: product, value: '10x10x10cm')
      end
    end

    # Producto 2
    factory :product_2 do 
      name {"Lavadora 8 Kg WCE 660 TwinDos WiFi"}
      price {1449990}
      sku   {"10545430"}
      product_type {'MDA'}

      factory :product_comparable_2 do 
        after(:create) do |product|
          product.families << (Family.find_by(name: 'Cocción') || create(:business_unit))
          product.families << (Family.find_by(name: 'Cocina') || create(:family_1))
          create(:product_attribute, comparable_attribute: create(:comparable_attribute), product: product, value: '20x15x50cm')
        end
      end

      factory :product_comparable_2_different do 
        after(:create) do |product|
          product.families << (Family.find_by(name: 'Cocción') || create(:business_unit))
          product.families << (Family.find_by(name: 'Hornos') || create(:family_diferent))
          create(:product_attribute, comparable_attribute: create(:comparable_attribute), product: product, value: '20x15x50cm')
        end
      end
    end
    # Producto 3
    factory :product_3 do 
      name {"Horno Multifunción H 2265 BP"}
      price {999990}
      sku   {"435F3490"}
      product_type {'MDA'}

      factory :product_comparable_3 do 
        after(:create) do |product|
          product.families << (Family.find_by(name: 'Cocción') || create(:business_unit))
          product.families << (Family.find_by(name: 'Cocina') || create(:family_1))
          create(:product_attribute, comparable_attribute: create(:comparable_attribute), product: product, value: '20x15x50cm')
        end
      end
    end
    # Producto 4
    factory :product_4 do 
      name {"Microondas Independiente M6012"}
      price {549990}
      sku   {"3454TRE7"}
      product_type {'SDA'}

      factory :product_comparable_4 do 
        after(:create) do |product|
          product.families << (Family.find_by(name: 'Cocción') || create(:business_unit))
          product.families << (Family.find_by(name: 'Cocina') || create(:family_1))
          create(:product_attribute, comparable_attribute: create(:comparable_attribute), product: product, value: '20x15x50cm')
        end
      end
    end
    # Producto 5
    factory :product_5 do 
      name {"Cava de Vino Empotrable KWT 6112"}
      price {2139990}
      sku   {"987R4542"}
      product_type {'MDA'}
    end
    # Producto 6
    factory :product_6 do 
      name {"Aspiradora Blizzard CX1 Comfort"}
      price {399990}
      sku   {"FFT64444"}
      product_type {'SDA'}
    end

    factory :mandatory_product_ins do
      name {'Tabla de conexión 123'}
      sku {'132019'}
      price {50900}
      product_type {'SDA'}
      mandatory {true}
    end

    factory :pipes do
      name {'Ductos'}
      sku {'1000'}
      price {0}
      product_type {'SDA'}
      mandatory {true}
    end

    factory :bstock_1 do 
      ean {'MSKMAS12313'}
      price {699990}
      sku   {"105RR590"}
      category {'B1'}
      state {'Falta perilla'}
      discount {20}
      cost_center{create(:miele_exp_center)}

      after(:create) do |product|
        product.families << (Family.find_by(name: 'Cocción') || create(:business_unit))
      end
    end

    factory :bstock_2 do 
      ean {'KKOKSA123'}
      price {699990}
      sku   {"105RR590"}
      category {'B2'}
      state {'Falta filtros'}
      discount {30}
      cost_center {create(:piedra_roja)}

      after(:create) do |product|
        product.families << (Family.find_by(name: 'Cocción') || create(:business_unit))
      end
    end

    factory :pre_visit_product do
      name {'Pre-visita (IVA incluido)'}
      sku {'SERV01'}
      price {29900}
      product_type {'SDA'}
      mandatory {false}

      after(:create) do |product|
        product.families << (Family.find_by(name: 'Servicios') || create(:services_family))
      end
    end

    factory :home_program_product do
      name {'Home Program'}
      sku {'PEM'}
      price {99990}
      product_type {'SDA'}
      mandatory {false}

      after(:create) do |product|
        product.families << (Family.find_by(name: 'Servicios') || create(:services_family))
      end
    end
  end
end
