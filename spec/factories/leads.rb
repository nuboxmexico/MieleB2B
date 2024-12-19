FactoryBot.define do
  factory :lead do
    name { "Nombre del lead" }
    real_state_name { "Inmobiliaria" }
    contacts { "Datos de contacto" }
    project_address { "Dirección del proyecto" }
    start_date_estimated { "2020-12-01" }
    currency { 1 }
    observations { "Observaciones" }
    status { 0 }

    before :create do |lead|
      lead.products << create(:lead_product, sku: 'sku1-lead', unit_price: 10000, name: 'Primer Producto de Lead')
      lead.products << create(:lead_product, sku: 'sku2-lead', unit_price: 5000, name: 'Segundo Producto de Lead', quantity: 2)

      lead.attachments << create(:lead_attachment)
    end
  end
end
