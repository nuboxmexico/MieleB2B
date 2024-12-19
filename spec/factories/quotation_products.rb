FactoryBot.define do
  factory :quotation_product do
    quotation { nil }
    product { Product.last || create(:product) }
    name { "Máquina de Café CM5300" }
    price { 699990 }
    quantity { 1 }
    sku { "105RR590" }
    mandatory { false }
    dispatch { false }
    available {true}

    factory :quotation_product_2 do 
        product { Product.find_by(name: 'Cava de Vino Empotrable KWT 6112') || create(:product_5) }
        name { "Cava de Vino Empotrable KWT 6112" }
        price { 2139990 }
        quantity { 2 }
        sku { "987R4542" }
        mandatory { false }
        dispatch { false }
        available {true}
    end

    factory :quotation_product_3 do 
        product { Product.find_by(name: 'Horno Multifunción H 2265 BP') || create(:product_3) }
        name { "Horno Multifunción H 2265 BP" }
        price { 999990 }
        quantity { 1 }
        sku { "987R4542" }
        mandatory { false }
        dispatch { false }
        available {true}
    end

    factory :retail_quotation_product do 
        quotation { nil }
        product { Product.last || create(:product) }
        name { "Máquina de Café CM5300" }
        price { 699990 }
        quantity { 1 }
        sku { "105RR590" }
        mandatory { false }
        dispatch { false }
        instalation { false }
        is_service { false }
        max_quantity { 3 }
        available {true}
        tnr_retail {'ABC123'}
        branch_name {'PARQUE ARAUCO'}
        branch_number {'123'}
    end
end
end
