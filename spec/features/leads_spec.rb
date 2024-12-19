require 'rails_helper'
describe 'Leads', type: :feature do 
  let(:user){create(:project_user)}
  before do 
    login_as(user, scope: :user)
    Rake::Task.define_task(:environment)
  end
  
  after do 
    Rake.application.clear
  end

  context 'admin' do 

    it 'index', js: true do 
      lead_1 = create(:lead)
      lead_2 = create(:lead)
      
      visit root_path
      expect(page).to have_current_path(root_path)

      expect(page).to have_selector('#leads-section')
      find('#leads-section').click
      expect(page).to have_selector('#leads-index')
      find('#leads-index').click

      expect(page).to have_current_path(leads_path)

      expect(page).to have_selector('.leads-container')

      within first('.leads-container') do 
        expect(page).to have_selector('.header')
        within first('.header') do 
          expect(page).to have_content('Fecha de creación')
          expect(page).to have_content('Nombre')
          expect(page).to have_content('Inmobiliaria')
          expect(page).to have_content('Fecha estimada de inicio')
          expect(page).to have_content('Estado')
          expect(page).to have_content('Acciones')
        end

        expect(page).to have_selector('.lead')
        leads_containers = all('.lead')
        expect(leads_containers.size).to be 2

        within leads_containers[0] do 
          expect(page).to have_content(lead_1.created_at.strftime('%d/%m/%Y'))
          expect(page).to have_content(lead_1.name)
          expect(page).to have_content(lead_1.real_state_name)
          expect(page).to have_content(lead_1.start_date_estimated.strftime('%d/%m/%Y'))
          expect(page).to have_content(lead_1.status_name)
          expect(page).to have_selector("a[href='#{lead_path(lead_1)}']")
          expect(page).to have_selector("a[href='#{edit_lead_path(lead_1)}']")
        end

        within leads_containers[1] do 
          expect(page).to have_content(lead_2.created_at.strftime('%d/%m/%Y'))
          expect(page).to have_content(lead_2.name)
          expect(page).to have_content(lead_2.real_state_name)
          expect(page).to have_content(lead_2.start_date_estimated.strftime('%d/%m/%Y'))
          expect(page).to have_content(lead_2.status_name)
          expect(page).to have_selector("a[href='#{lead_path(lead_2)}']")
          expect(page).to have_selector("a[href='#{edit_lead_path(lead_2)}']")
        end
      end
    end

    it 'sort in index', js: true do 
      lead_1 = create(:lead, name: 'lead 1')
      lead_2 = create(:lead, name: 'lead 2')
      lead_3 = create(:lead, name: 'lead 3')
      
      visit leads_path
      expect(page).to have_current_path(leads_path)

      within first('.leads-container') do 
        leads_containers = all('.lead')
        expect(leads_containers.count).to be 3

        expect(leads_containers[0]).to have_content(lead_1.name)
        expect(leads_containers[1]).to have_content(lead_2.name)
        expect(leads_containers[2]).to have_content(lead_3.name)

        within first('.header') do 
          expect(page).to have_selector('.sort-link')
          first('.sort-link').click
        end
      end

      expect(page).to have_current_path(leads_path(q: {s: 'created_at asc'}))
      first('.sort-link').click
      expect(page).to have_current_path(leads_path(q: {s: 'created_at desc'}))

      within first('.leads-container') do 
        leads_containers = all('.lead')

        expect(leads_containers[0]).to have_content(lead_3.name)
        expect(leads_containers[1]).to have_content(lead_2.name)
        expect(leads_containers[2]).to have_content(lead_1.name)
      end
    end

    it 'search', js: true do 
      lead_1 = create(:lead, name: 'lead 1')
      lead_2 = create(:lead, name: 'lead 2')
      lead_3 = create(:lead, name: 'lead 3')
      
      visit leads_path
      expect(page).to have_current_path(leads_path)
      
      expect(page).to have_content(lead_1.name)
      expect(page).to have_content(lead_2.name)
      expect(page).to have_content(lead_3.name)

      expect(page).to have_selector('.search-container')

      within first('.search-container') do 
        fill_in 'search-lead-input', with: 'lead 3'
        click_button 'Buscar'
      end

      expect(page).not_to have_current_path(leads_path)

      expect(page).not_to have_content(lead_1.name)
      expect(page).not_to have_content(lead_2.name)
      expect(page).to have_content(lead_3.name)
    end

    it '# create', js: true do 
      visit new_lead_path
      expect(page).to have_current_path(new_lead_path)
      expect(page).to have_content('Nuevo Lead')

      expect(Lead.count).to be 0

      expect(page).to have_selector('.lead-form')
      within first('.lead-form') do 
        fill_in 'lead[name]', with: 'Nombre lead'
        fill_in 'lead[real_state_name]', with: 'Nombre inmobiliaria'
        within_frame('lead_contacts_ifr') do
          editor = page.find_by_id('tinymce')
          editor.native.send_keys ', Datos de contacto'
        end
        fill_in 'lead[project_address]', with: 'Dirección del proyecto'
        fill_in 'lead[start_date_estimated]', with: '12213'
        select 'USD', from: 'lead[currency]'
        within_frame('lead_observations_ifr') do
          editor = page.find_by_id('tinymce')
          editor.native.send_keys ', Observaciones'
        end
        select 'Iniciado', from: 'lead[status]'

        expect(page).to have_selector('.products')
        products_containers = all('.products')

        within products_containers.first do 
          expect(page).to have_content('Productos')
        end

        within products_containers.last do 
          expect(page).to have_selector('.product-inputs')
          expect(page).to have_selector('#product-inputs-container')
          expect(all('.product-inputs').size).to be 1

          fill_in 'lead[products_attributes][0][sku]', with: 'TNR123'
          fill_in 'lead[products_attributes][0][name]', with: 'nombre producto'
          fill_in 'lead[products_attributes][0][unit_price]', with: '12313'
          fill_in 'lead[products_attributes][0][quantity]', with: '1'
          
          expect(page).to have_selector('.total-net-price')
          expect(page).to have_selector('.total-tax-value')
          expect(page).to have_selector('.total-price')

          #para gatillar el evento change
          first('.total-price').click
          wait_for_ajax
          
          expect(first('.total-net-price')).to have_content('12.313,00')
          expect(first('.total-tax-value')).to have_content('2.339,47')
          expect(first('.total-price')).to have_content('14.652,47')
        end

        expect(page).to have_selector('#lead-totals')
        within find('#lead-totals') do 
          expect(page).to have_selector('.net-price')
          expect(find('.net-price')).to have_content('12.313,00')
          expect(page).to have_selector('.tax-value')
          expect(find('.tax-value')).to have_content('2.339,47')
          expect(page).to have_selector('.price')
          expect(find('.price')).to have_content('14.652,47')
        end

        within products_containers.last do 
          expect(page).to have_selector('#add-product')
          click_link 'Agregar producto'
          wait_for_ajax

          expect(all('.product-inputs').size).to be 2

          fill_in 'lead[products_attributes][1][sku]', with: 'TNR321'
          fill_in 'lead[products_attributes][1][name]', with: 'nombre producto 2'
          fill_in 'lead[products_attributes][1][quantity]', with: '21'
          fill_in 'lead[products_attributes][1][unit_price]', with: '5990'

          first('.total-price').click
          wait_for_ajax

          expect(all('.total-net-price').last).to have_content('125.790,00')
          expect(all('.total-tax-value').last).to have_content('23.900,10')
          expect(all('.total-price').last).to have_content('149.690,10')
        end

        within find('#lead-totals') do 
          expect(page).to have_selector('.net-price')
          expect(find('.net-price')).to have_content('138.103,00')
          expect(page).to have_selector('.tax-value')
          expect(find('.tax-value')).to have_content('26.239,57')
          expect(page).to have_selector('.price')
          expect(find('.price')).to have_content('164.342,57')
        end

        execute_script("$('#lead_attachments').removeClass('file-input')")
        attach_file 'lead[attachments][]', "#{Rails.root}/spec/aux/105RR590.png"

        find('input[type="submit"]').click
      end

      expect(Lead.count).to be 1
      lead = Lead.first
      expect(lead.name).to eq 'Nombre lead'
      expect(lead.products.count).to be 2
      expect(lead.attachments.count).to be 1

      expect(page).to have_current_path(lead_path(lead))
    end

    it '# show', js: true do 
      lead = create(:lead)
      visit lead_path(lead)
      expect(page).to have_current_path(lead_path(lead))

      expect(page).to have_link('Editar', href: edit_lead_path(lead))

      expect(page).to have_selector('.lead-container')

      expect(page).to have_content('Nombre del Lead')
      expect(page).to have_content(lead.name)
      expect(page).to have_content('Nombre Inmobiliaria')
      expect(page).to have_content(lead.real_state_name)
      expect(page).to have_content('Dirección del proyecto')
      expect(page).to have_content(lead.project_address)
      expect(page).to have_content('Fecha estimada de inicio')
      expect(page).to have_content(lead.start_date_estimated.strftime('%d/%m/%Y'))
      expect(page).to have_content('Contactos')
      expect(page).to have_content(lead.contacts)
      expect(page).to have_content('Observaciones')
      expect(page).to have_content(lead.observations)
      expect(page).to have_content('Moneda')
      expect(page).to have_content(Lead.currency_options[lead.currency])
      expect(page).to have_content('Estado')
      expect(page).to have_content(lead.status_name)

      products = lead.products
      expect(products.size).to be 2
      expect(page).to have_selector('.products-container')
      within first('.products-container') do 
        products_containers = all('.product')
        expect(products_containers.count).to be 2

        within products_containers[0] do 
          expect(page).to have_content('TNR')
          expect(page).to have_content(products[0].sku)
          expect(page).to have_content('Nombre')
          expect(page).to have_content(products[0].name)
          expect(page).to have_content('Cantidad')
          expect(page).to have_content(products[0].quantity)
          expect(page).to have_content('Precio')
          expect(page).to have_content('10.000,0')
          
          expect(page).to have_content('Total Neto')
          expect(first('.total-net-price')).to have_content('10.000,0')
          expect(page).to have_content('Total IVA')
          expect(first('.total-tax-value')).to have_content('1.900,0')
          expect(page).to have_content('Total IVA + Total Neto')
          expect(first('.total-price')).to have_content('11.900,0')
        end
        
        within products_containers[1] do 
          expect(page).to have_content('TNR')
          expect(page).to have_content(products[1].sku)
          expect(page).to have_content('Nombre')
          expect(page).to have_content(products[1].name)
          expect(page).to have_content('Cantidad')
          expect(page).to have_content(products[1].quantity)
          expect(page).to have_content('Precio')
          expect(page).to have_content('5.000,0')

          expect(page).to have_content('Total Neto')
          expect(first('.total-net-price')).to have_content('10.000,0')
          expect(page).to have_content('Total IVA')
          expect(first('.total-tax-value')).to have_content('1.900,0')
          expect(page).to have_content('Total IVA + Total Neto')
          expect(first('.total-price')).to have_content('11.900,0')
        end
      end

      expect(lead.attachments.size).to be 1
      expect(page).to have_selector('.attachments-container')
      within first('.attachments-container') do 
        expect(page).to have_selector('.attachment')
        expect(page).to have_link(lead.attachments.first.file_file_name)
      end

      expect(page).to have_selector('#lead-totals')
      within find('#lead-totals') do 
        expect(page).to have_selector('.net-price')
        expect(find('.net-price')).to have_content('20.000,0')
        expect(page).to have_selector('.tax-value')
        expect(find('.tax-value')).to have_content('3.800,0')
        expect(page).to have_selector('.price')
        expect(find('.price')).to have_content('23.800,0')
      end
    end

    it '# edit', js: true do 
      lead = create(:lead)
      expect(lead.products.count).to be 2

      visit edit_lead_path(lead)
      expect(page).to have_current_path(edit_lead_path(lead))

      expect(page).to have_content("Editar Lead #{lead.name}")

      expect(page).to have_content(lead.name)
      expect(page).to have_content(lead.real_state_name)
      expect(page).to have_content(lead.project_address)

      fill_in 'lead[name]', with: 'Nuevo Nombre lead'
      fill_in 'lead[real_state_name]', with: 'Nuevo Nombre inmobiliaria'
      fill_in 'lead[project_address]', with: 'Nueva Dirección del proyecto'

      click_link 'Agregar producto'
      wait_for_ajax

      fill_in 'lead[products_attributes][2][sku]', with: 'Nuevo TNR'
      fill_in 'lead[products_attributes][2][name]', with: 'nombre nuevo producto 2'
      fill_in 'lead[products_attributes][2][quantity]', with: '21'
      fill_in 'lead[products_attributes][2][unit_price]', with: '5990'

      expect(page).to have_button('Guardar')
      click_button 'Guardar'

      # lead = Lead.find(lead.id)
      # expect(lead.products.count).to be 3

      expect(page).to have_current_path(lead_path(lead))
      expect(page).to have_content('Nuevo Nombre lead')
      expect(page).to have_content('Nuevo Nombre inmobiliaria')
      expect(page).to have_content('Nueva Dirección del proyecto')

      expect(all('.products-container .product').size).to be 3
      expect(page).to have_content('Nuevo TNR')
    end

    it 'download by date range', js: true do 
      Capybara.current_driver = :webkit
      Timecop.freeze(Date.new(2020, 07, 01))
      
      lead_1 = create(:lead, name: 'lead 1', created_at: 2.days.ago)
      lead_2 = create(:lead, name: 'lead 2', created_at: 1.day.ago)
      lead_3 = create(:lead, name: 'lead 3')
      
      visit leads_path
      expect(page).to have_current_path(leads_path)

      expect(page).to have_selector('#leads-daterange-filter')

      fill_in 'leads-daterange-filter', with: "#{1.day.ago.strftime('%d/%m/%Y')} - #{Date.today.strftime('%d/%m/%Y')}"

      expect(page).to have_selector('.daterangepicker .applyBtn')
      first('.daterangepicker .applyBtn').click

      expect(page.response_headers['Content-Disposition']).to eq "attachment; filename=\"Leads_#{Date.today.strftime("%d-%m-%Y")}.xlsx\""

      Timecop.return
      Capybara.use_default_driver
    end
  end

  context 'to quotation' do 
    let(:lead){create(:lead)}

    before do 
      create(:lead_state)
      create(:pendiente)
    end
    
    it 'and check if sku exists', js: true do 
      product = create(:product)
      lead.products << create(:lead_product, sku: product.sku)

      expect(lead.products.count).to be 3
      expect(Product.where(sku: lead.products.map{|l| l.sku}).count).to be 1

      visit lead_path(lead)
      expect(page).to have_current_path(lead_path(lead))

      expect(page).to have_link('Crear cotización', href: lead_to_quotation_path(lead))
      expect(page).to have_content(product.sku)

      expect(page).to have_selector('.existing-sku-alert[data-existing-message="TNR ya registrado"]')
      existing_sku_tags = all('.existing-sku-alert')

      expect(existing_sku_tags.size).to be 1

      expect(page).not_to have_selector('.swal2-modal')
      click_link 'Crear cotización'
      expect(page).to have_selector('.swal2-modal')
      within first('.swal2-modal') do 
        expect(page).to have_content('Hay TNRs en este Lead que ya están registrados en Miele Customers')
        expect(page).to have_content('Esto podría implicar cambios en el nombre de los productos cuyos TNR ya están registrados')
        first('.swal2-confirm').click
      end

      expect(Quotation.count).to be 1
      quotation = Quotation.last

      expect(page).to have_current_path(edit_quotation_path(quotation))
    end

    it '# create', js: true do
      expect(Quotation.count).to be 0
      products = lead.products
      expect(products.count).to be 2
      visit lead_path(lead)
      expect(page).to have_current_path(lead_path(lead))

      expect(all('.existing-sku-alert').count).to be 0
      expect(page).to have_link('Crear cotización', href: lead_to_quotation_path(lead))
      click_link 'Crear cotización'

      expect(Quotation.count).to be 1
      quotation = Quotation.last

      expect(page).to have_current_path(edit_quotation_path(quotation))
      expect(find('#quotation_project_name').value).to have_content(lead.name)
      expect(find('#quotation_real_state_name').value).to have_content(lead.real_state_name)
      expect(page).to have_content("#{products[0].quantity} x #{products[0].name} 10.000")
      expect(page).to have_content("#{products[1].quantity} x #{products[1].name} 10.000")

      click_button 'Generar'

      expect(quotation.products.count).to be 2
      expect(quotation.products.find_by(sku: products[0].sku)).not_to be nil
      expect(quotation.products.find_by(sku: products[1].sku)).not_to be nil
      expect(quotation.currency).to eq lead.currency
      expect(quotation.lead).to eq lead

      expect(page).to have_current_path(quotation_path(quotation))
      expect(page).to have_link('Ver lead', href: lead_path(lead))

      lead = Lead.find_by(id: quotation.lead.id)
      expect(lead.in_negotiation?).to be true
    end
  end
end