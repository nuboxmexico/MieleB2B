require 'rails_helper'
describe 'Quotation', type: :feature do 
	include ActiveJob::TestHelper
	let(:user){create(:user)}
	let(:retail_user){create(:retail_user)}

	context 'Create' do
		before do 
			login_as(user, scope: :user)
			create(:santiago)
			create(:providencia)
			create(:enviada)
			ActionMailer::Base.deliveries = []
			clear_enqueued_jobs
		end

		it 'from products', js: true do
			user = create(:seller_user)
			login_as(user, scope: :user)
			product = create(:product)
			product.sale_channels << user.sale_channel
			family = create(:business_unit)
			family.products << product
			visit products_path(business_unit: family.name)

			expect(page).to have_current_path(products_path(business_unit: family.name))
			first('.fa-cart-plus').click
			wait_for_ajax
			sleep(1)
			expect(page).to have_content('Producto agregado con éxito')
			sleep(5)
			expect(page).to have_css("#items-in-cart", text: "1")
			sleep(1)
			first('#shopping-cart').click
			visit cart_path
			expect(page).to have_current_path(cart_path)
			expect(page).to have_content('105RR590')
			expect(page).to have_content('Máquina de Café CM5300')
			expect(page).to have_content('699.990')
			first('#toggle-discounts').click
			wait_for_ajax
			within '#indicator' do
				expect(page).to have_content('6.300.010,0 5 %')
			end
			first('#continue-link').click

			expect(page).to have_current_path(new_quotation_path(currency: 'clp', 
																													 exchange_rate: '1', 
																													 exchange_rate_date: DateTime.current.strftime("%d/%m/%Y"))
																			 )
			# llena formulario completo
			fill_form

			within '.card-shadow' do
				expect(page).to have_content(user.email)
				expect(page).to have_content(user.miele_role.code)
				expect(page).to have_content(user.fullname)
				expect(page).to have_content(user.role_name)
				expect(page).to have_content(user.phone)
			end

			#cambiar en un futuro
			expect(page).to have_content('Cotización válida durante 30 días')
			sleep(1)
			find('#submit-quotation').click
			
			quotation = Quotation.last
			expect(quotation.mobile_phone).to eq '123456789'

			expect(page).to have_current_path(quotation_resumen_path(quotation))
			expect(page).to have_content('¡Cotización Creada!')
			expect(page).to have_content('Cotización ID '+quotation.code+' válida hasta el '+(Date.today + 30.days).strftime("%d/%m/%Y")+' ha sido ingresada de forma exitosa.')
			expect(page).to have_content('En breves minutos recibirá un correo a prueba@chile.net con la cotización e información de forma de pago.')
			expect(enqueued_jobs.size).to be 2
			expect(Customer.count).to be 1
		end
		
		it 'with bill', js: true do
			user = create(:seller_user)
			login_as(user, scope: :user)
			create(:cart_with_product_next_level, user: user)
			visit cart_path
			expect(page).to have_content('Sub Total Dcto. por Tramo -5% 7.699.890 -384.989')
			within '#cart-total-cost-1' do
				expect(page).to have_content('7.314.901 (IVA Incluído)')
			end
			within '#indicator' do
				expect(page).to have_content('9.300.110 10 %')
			end

			first('#continue-link').click
			expect(page).to have_current_path(new_quotation_path(currency: 'clp',
																													 exchange_rate: '1',
																													 exchange_rate_date: DateTime.current.strftime("%d/%m/%Y"))
																			  )
			# llena formulario completo
			fill_form

			first('#factura-label').click

			fill_in 'quotation_business_name', with: 'Garage Labs'
			fill_in 'quotation_business_rut', with: '111111111'

			fill_in 'quotation_billing_address', with: 'Calle verdadera'
			fill_in 'quotation_billing_address_number', with: '456'
			fill_in 'quotation_billing_dpto_number', with: '1532'

			within '#billing-commune-content' do
				find('.select2-container').click
			end
			find(".select2-search__field").set('Providencia')

			within ".select2-results__options" do
				find('li', text: 'Providencia').click
			end

			first('#instalation-collapsable').click
			sleep(1)
			fill_in 'quotation_instalation_address', with: 'Calle verdadera'
			fill_in 'quotation_instalation_address_number', with: '456'
			fill_in 'quotation_instalation_dpto_number', with: '1532'
			within '#instalation-commune-content' do
				find('.select2-container').click
			end
			find(".select2-search__field").set('Providencia')
			within ".select2-results__options" do
				find('li', text: 'Providencia').click
			end

			#cambiar en un futuro
			delivered_emails = ActionMailer::Base.deliveries.count
			expect(page).to have_content('Cotización válida durante 30 días')
			find('#submit-quotation').click

			wait_for_ajax

			quotation = Quotation.last
			expect(quotation.mobile_phone).to eq '123456789'

			expect(page).to have_current_path(quotation_resumen_path(quotation))
			expect(page).to have_content('¡Cotización Creada!')
			expect(page).to have_content('Cotización ID '+quotation.code+' válida hasta el '+(Date.today + 30.days).strftime("%d/%m/%Y")+' ha sido ingresada de forma exitosa.')
			expect(page).to have_content('En breves minutos recibirá un correo a prueba@chile.net con la cotización e información de forma de pago.')
			expect(enqueued_jobs.size).to be 2
			expect(Customer.all.size).to eq 1
			expect(Customer.last.quotations.last).to eq quotation
		end

		it 'with autocomplete customer', js: true do 
			user = create(:seller_user)
			login_as(user, scope: :user)
			create(:cart_with_product_next_level, user: user)
			mca_user = create(:mca_user)
			create(:customer, user: mca_user)
			clear_enqueued_jobs
			visit cart_path
			expect(page).to have_content('Sub Total Dcto. por Tramo -5% 7.699.890 -384.989')
			within '#cart-total-cost-1' do
				expect(page).to have_content('7.314.901 (IVA Incluído)')
			end
			within '#indicator' do
				expect(page).to have_content('9.300.110 10 %')
			end

			first('#continue-link').click
			expect(page).to have_current_path(new_quotation_path(currency: 'clp', 
																													 exchange_rate: '1', 
																													 exchange_rate_date: Date.today.strftime('%d/%m/%Y')))
			fill_in 'quotation_rut', with: '11'
			wait_for_ajax
			sleep(2)
			first('.ui-menu-item-wrapper').click

			first('#instalation-collapsable').click
			sleep(1)
			fill_in 'quotation_instalation_address', with: 'Calle verdadera'
			fill_in 'quotation_instalation_address_number', with: '456'
			fill_in 'quotation_instalation_dpto_number', with: '1532'
			within '#instalation-commune-content' do
				find('.select2-container').click
			end
			find(".select2-search__field").set('Providencia')
			within ".select2-results__options" do
				find('li', text: 'Providencia').click
			end

			expect(page).to have_content('Cotización válida durante 30 días')
			
			find('#submit-quotation').click

			wait_for_ajax
			expect(page).to have_current_path(quotation_resumen_path(Quotation.first))
			expect(page).to have_content('¡Cotización Creada!')
			expect(page).to have_content('Cotización ID '+Quotation.first.code+' válida hasta el '+(Date.today + 30.days).strftime("%d/%m/%Y")+' ha sido ingresada de forma exitosa.')
			expect(page).to have_content('En breves minutos recibirá un correo a hola@prueba.net con la cotización e información de forma de pago.')
			expect(enqueued_jobs.size).to be 2
			expect(Customer.count).to eq 1
			expect(Customer.last.user).to eq User.last
			expect(Customer.last.instalation_address).to eq 'Calle verdadera'
			expect(Quotation.first.name).to eq 'Usuario'
			expect(Quotation.first.referred_user).to eq mca_user
		end

		it 'with autocomplete customer and dispatch code', js: true do 
			user = create(:seller_user)
			login_as(user, scope: :user)
			create(:project_business_sale_channel)
			create(:own_retail_sale_channel)
			create(:retail_sale_channel)
			create(:ecommerce_sale_channel)
			create(:cart_with_product_next_level, user: user)
			dispatch_code = create(:unlimited_code, is_for_product: false, end_date: Date.today+1.days)
			dispatch_code.sale_channels << SaleChannel.all
			mca_user = create(:mca_user)
			create(:customer, user: mca_user)
			clear_enqueued_jobs
			visit cart_path
			expect(page).to have_content('Sub Total Dcto. por Tramo -5% 7.699.890 -384.989')
			within '#cart-total-cost-1' do
				expect(page).to have_content('7.314.901 (IVA Incluído)')
			end
			within '#indicator' do
				expect(page).to have_content('9.300.110 10 %')
			end

			first('#continue-link').click
			expect(page).to have_current_path(new_quotation_path(currency: 'clp', 
																													 exchange_rate: '1', 
																													 exchange_rate_date: Date.today.strftime('%d/%m/%Y')))
			fill_in 'quotation_rut', with: '11'
			wait_for_ajax
			sleep(2)
			first('.ui-menu-item-wrapper').click
			# expect(page).to have_content('RUT asociado a MCA, Manager MCA Materno, cotización: 36-618-1-prueba del '+Date.today.strftime("%d/%m/%Y"))
			first('#instalation-collapsable').click
			sleep(1)
			fill_in 'quotation_instalation_address', with: 'Calle verdadera'
			fill_in 'quotation_instalation_address_number', with: '456'
			fill_in 'quotation_instalation_dpto_number', with: '1532'
			within '#instalation-commune-content' do
				find('.select2-container').click
			end
			find(".select2-search__field").set('Providencia')
			within ".select2-results__options" do
				find('li', text: 'Providencia').click
			end

			first('#toggle-dispatch-button').click
			sleep(1)
			fill_in 'dispatch-code', with: dispatch_code.code
			first('#submit-code').click
			wait_for_ajax
			expect(page).to have_content('Sub Total 7.699.890')
			expect(page).to have_content('Despacho + Instalación 383.900')
			expect(page).to have_content('Dcto. por Tramo -5% -384.989')
			expect(page).to have_content('Dcto. Despacho 30OFF (-30%) - 115.170')
			within '#cart-total-cost-1' do
				expect(page).to have_content('7.583.631,0 (IVA Incluído)')
			end

			expect(page).to have_content('Cotización válida durante 30 días')
			
			find('#submit-quotation').click
			
			expect(page).to have_current_path(quotation_resumen_path(Quotation.last))
			expect(page).to have_content('¡Cotización Creada!')
			expect(page).to have_content('Cotización ID '+Quotation.last.code+' válida hasta el '+(Date.today + 30.days).strftime("%d/%m/%Y")+' ha sido ingresada de forma exitosa.')
			expect(page).to have_content('En breves minutos recibirá un correo a hola@prueba.net con la cotización e información de forma de pago.')
			expect(enqueued_jobs.size).to be 2
			expect(Customer.all.size).to eq 1
			expect(Customer.last.user).to eq User.last
			expect(Customer.last.instalation_address).to eq 'Calle verdadera'
			expect(Quotation.last.name).to eq 'Usuario'
			expect(Quotation.last.referred_user).to eq mca_user
		end
	end

	context 'View' do
		before do
			login_as(user, scope: :user)
		end
		it 'index page', js: true do
			create(:quotation)
			visit quotations_path
			expect(page).to have_current_path(quotations_path)
			expect(page).to have_content('Código 36-618-1-prueba Cliente Usuario prueba materno RUT 11111111-1 Correo hola@prueba.net')
		end

		it 'search and show list with normal user', js: true do
			quotation = create(:quotation)
			visit quotations_path
			expect(page).to have_current_path(quotations_path)

			fill_in 'search_quotations', with: 'rancagua'
			wait_for_ajax
			expect(page).to have_content('No se encontraron resultados')
			execute_script('$("#searcher-form").submit()')
			expect(all('.panel').length).to be 0

			fill_in 'search_quotations', with: 'falsa'
			wait_for_ajax
			expect(all('.select2-row').length).to be 1
			execute_script('$("#searcher-form").submit()')
			expect(all('.panel').length).to be 1

			fill_in 'search_quotations', with: 'hola'
			wait_for_ajax
			expect(all('.select2-row').length).to be 1
			first('.select2-row').click
			expect(page).to have_current_path(quotation_path(quotation))

			visit quotations_path

			fill_in 'search_quotations', with: '11111111-1'
			wait_for_ajax
			expect(all('.select2-row').length).to be 1

			fill_in 'search_quotations', with: 'prueba'
			wait_for_ajax
			expect(all('.select2-row').length).to be 1

			fill_in 'search_quotations', with: 'santi'
			wait_for_ajax
			expect(all('.select2-row').length).to be 1
		end
	end

	context 'Retail' do 
		before do
			login_as(retail_user, scope: :user)
		end

		it 'search', js: true do 
			quotation = create(:retail_quotation)
			Product.first.retail_products << create(:retail_product, retail: Retail.first, tnr: 'ABC123')

			visit quotations_path
			expect(page).to have_current_path(quotations_path)

			fill_in 'search_quotations', with: '105RR'
			wait_for_ajax
			expect(all('.select2-row').length).to be 1

			fill_in 'search_quotations', with: ''
			wait_for_ajax
			sleep(1)
			expect(all('.select2-row').length).to be 0

			fill_in 'search_quotations', with: 'ABC12'
			wait_for_ajax
			expect(all('.select2-row').length).to be 1

			fill_in 'search_quotations', with: ''
			wait_for_ajax
			sleep(1)
			expect(all('.select2-row').length).to be 0

			fill_in 'search_quotations', with: '9876'
			wait_for_ajax
			expect(all('.select2-row').length).to be 1

			fill_in 'search_quotations', with: ''
			wait_for_ajax
			sleep(1)
			expect(all('.select2-row').length).to be 0

			fill_in 'search_quotations', with: '1234'
			wait_for_ajax
			expect(all('.select2-row').length).to be 1

			fill_in 'search_quotations', with: ''
			wait_for_ajax
			sleep(1)
			expect(all('.select2-row').length).to be 0

			fill_in 'search_quotations', with: 'fala'
			wait_for_ajax
			expect(all('.select2-row').length).to be 1
		end
	end

	context 'dispatch groups' do 
		let(:quotation){create(:quotation_in_preparation, quotation_state: create(:en_preparacion))}
		let(:user){create(:manager_dispatch_user)}

		before do 
			login_as(user, scope: :user)
		end

		it '# new from quantities changes', js: true do 
			expect(quotation.get_state).to eq 'En preparación'
			expect(quotation.products.count).to be 3
			expect(quotation.dispatch_groups.count).to be 0

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(page).to have_content('Detalles de despacho')
			expect(first('.state-label')).to have_content('En preparación')

			expect(page).to have_selector('.products-pending-of-dispatch-container')
			within first('.products-pending-of-dispatch-container') do 
				expect(page).to have_content('Productos pendientes de envío')
				expect(page).to have_content("#{quotation.quotation_products[0].product.name_and_sku} #{quotation.quotation_products[0].quantity}")
				expect(page).to have_content("#{quotation.quotation_products[1].product.name_and_sku} #{quotation.quotation_products[1].quantity}")
				expect(page).to have_content("#{quotation.quotation_products[2].product.name_and_sku} #{quotation.quotation_products[2].quantity}")
			end
			expect(page).not_to have_content('Envío N° 1')



			expect(page).to have_link('Nuevo envío', href: new_dispatch_group_path(quotation))
			click_link 'Nuevo envío'
			wait_for_ajax
			all('.save-dispatch').last.click

			expect(page).to have_content('Envío N° 1')

			expect(page).to have_selector('.dispatch-group-container')
			expect(all('.dispatch-group-container').count).to be 2

			dispatch_group_container = all('.dispatch-group-container').last
			dispatch_group = quotation.dispatch_groups.first
			expect(dispatch_group.products.count).to be 3
			within dispatch_group_container do 
				expect(page).to have_content('En preparación')
				expect(page).to have_content(dispatch_group.products[0].sku)
				expect(page).to have_content(dispatch_group.products[1].sku)
				expect(page).to have_content(dispatch_group.products[2].sku)
				expect(page).to have_content("Técnico")
				expect('dispatch_group[technician_id]')
				fill_in 'dispatch_group[product_in_dispatch_groups_attributes][1][quantity]', with: 0
				fill_in 'dispatch_group[product_in_dispatch_groups_attributes][2][quantity]', with: 0
				first('.save-dispatch').click
			end

			expect(page).to have_current_path(quotation_path(quotation))
			dispatch_group_containers = all('.dispatch-group-container')
			expect(dispatch_group_containers.count).to be 2
			expect(page).to have_content('Hay productos pertenecientes a la cotización que no tienen un envío asignado')

			products_in_first_dispatch = dispatch_group.products_in_dispatch.order(id: :asc)
			expect(products_in_first_dispatch[0].quantity).to be 1
			expect(products_in_first_dispatch[1].quantity).to be 0
			expect(products_in_first_dispatch[2].quantity).to be 0

			within first('.products-pending-of-dispatch-container') do 
				expect(page).to have_content("#{products_in_first_dispatch[0].product.name_and_sku} ")
				expect(page).to have_content("#{products_in_first_dispatch[1].product.name_and_sku} 2")
				expect(page).to have_content("#{products_in_first_dispatch[2].product.name_and_sku} 3")
			end
		end

		it 'delete', js: true do 
			create(:en_preparacion)
			create(:despachado)
			create(:dispatch_and_installations_state)
			first_dispatch_group = quotation.set_dispatch_group
			quotation.set_products_in_dispatch_group

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(all('.dispatch-group-container').count).to be 2

			fill_in 'dispatch_group[product_in_dispatch_groups_attributes][0][quantity]', with: 0
			first('.save-dispatch').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(all('.dispatch-group-container').count).to be 2
			
			within first('.dispatch-group-container') do 
				expect(page).to have_content('Productos pendientes de envío')
				expect(page).to have_content("#{quotation.quotation_products[0].product.name_and_sku}")
				expect(page).to have_content("#{quotation.quotation_products[1].product.name_and_sku}")
				expect(page).to have_content("#{quotation.quotation_products[2].product.name_and_sku}")

				pending_product = quotation.quotation_products.find_by('quantity > 0')
				expect(page).to have_content("#{pending_product.product.name_and_sku} #{pending_product.quantity}")
			end

			# Crea un nuevo grupo de envío
			quotation.new_dispatch_group.save
			first_dispatch_group.to_state('Despachado')
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			dispatch_group_containers = all('.dispatch-group-container')
			expect(dispatch_group_containers.count).to be 3

			within dispatch_group_containers[0] do 
				expect(page).to have_content('Productos pendientes de envío')
				expect(page).to have_content("#{quotation.quotation_products[0].product.name_and_sku} ")
				expect(page).to have_content("#{quotation.quotation_products[1].product.name_and_sku} ")
				expect(page).to have_content("#{quotation.quotation_products[2].product.name_and_sku}")
			end

			first('.collapse-dispatch-group-link').click

			within dispatch_group_containers[1] do 
				expect(page).to have_content('Despachado')
				expect(page).not_to have_selector('.fake-destroy-dispatch-group')

				products_in_dispatch = quotation.dispatch_groups
																				.first
																				.products_in_dispatch
																				.order(quantity: :asc)
				expect(page).to have_content("#{products_in_dispatch[0].product.name_and_sku} #{products_in_dispatch[0].quantity}")
				expect(page).to have_content("#{products_in_dispatch[1].product.name_and_sku} #{products_in_dispatch[1].quantity}")
				expect(page).to have_content("#{products_in_dispatch[2].product.name_and_sku} #{products_in_dispatch[2].quantity}")
			end

			within dispatch_group_containers[2] do 
				expect(page).to have_content('En preparación')
				expect(page).to have_selector('.fake-destroy-dispatch-group')

				products_in_dispatch = quotation.dispatch_groups
																				.last
																				.products_in_dispatch
																				.order(quantity: :asc)
				expect(first('input[name="dispatch_group[product_in_dispatch_groups_attributes][0][quantity]"]').value).to eq '1'
				expect(page).to have_content("#{products_in_dispatch[1].product.name_and_sku} -")
				expect(page).to have_content("#{products_in_dispatch[2].product.name_and_sku} -")
			end

			expect(page).not_to have_selector('.swal2-modal')
			first('.fake-destroy-dispatch-group').click
			expect(page).to have_selector('.swal2-modal')
			first('.swal2-confirm').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(all('.dispatch-group-container').count).to be 2

			within first('.dispatch-group-container') do 
				expect(page).to have_content('Productos pendientes de envío')
				expect(page).to have_content("#{quotation.quotation_products[0].product.name_and_sku}")
				expect(page).to have_content("#{quotation.quotation_products[1].product.name_and_sku}")
				expect(page).to have_content("#{quotation.quotation_products[2].product.name_and_sku}")

				pending_product = quotation.quotation_products.find_by('quantity > 0')
				expect(page).to have_content("#{pending_product.product.name_and_sku} #{pending_product.quantity}")
			end
		end

		it 'change state from in preparation to dispatched' do 
			create(:despachado)
			quotation.set_dispatch_group
			quotation.set_products_in_dispatch_group

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(page).to have_selector('.send-dispatch.disabled')
			expect(all('.dispatch-group-container').last).to have_content('En preparación')

			fill_in 'dispatch_group[dispatch_order]', with: '1234'
			fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'observaciones'
			attach_file 'dispatch_guide_documents', "#{Rails.root}/spec/aux/pdf_prueba.pdf", make_visible: true
			first('.save-dispatch').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).not_to have_selector('.send-dispatch.disabled')
			first('.send-dispatch').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(all('.dispatch-group-container').last).to have_content('Despachado')
		end

		it 'change state from dispatched to "to install"', js: true do 
			create(:por_instalar)
			quotation.set_dispatch_group
			quotation.set_products_in_dispatch_group
			quotation.dispatch_groups.last.update(state: create(:despachado))

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(all('.dispatch-group-container').last).to have_content('Despachado')

			first('.select2-container').click
			first('.select2-search__field').set('Recepción conforme por courier')

			within '.select2-results__options' do
				first('li', text: 'Recepción conforme por courier').click
			end

			fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'observaciones de despacho'

			find('input[type="submit"]').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(all('.dispatch-group-container').last).to have_content('Por Instalar')
		end

		it 'with multiple states', js: true do 
			create(:despachado)
			create(:quotation_state, name: 'Despachos e Instalaciones')
			quotation.set_dispatch_group
			quotation.set_products_in_dispatch_group

			expect(quotation.get_state).to eq 'En preparación'

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			fill_in 'dispatch_group[product_in_dispatch_groups_attributes][0][quantity]', with: 0
			first('.save-dispatch').click
			
			expect(page).to have_current_path(quotation_path(quotation))
			expect(all('.dispatch-group-container').size).to be 2	

			dispatch_groups_containers = all('.dispatch-group-container')
			
			within dispatch_groups_containers.last do
				expect(page).to have_content('En preparación')
				fill_in 'dispatch_group[dispatch_order]', with: '1234'
				fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'observaciones'
				attach_file 'dispatch_guide_documents', "#{Rails.root}/spec/aux/pdf_prueba.pdf", make_visible: true
				find('.save-dispatch').click
			end

			expect(page).to have_current_path(quotation_path(quotation))
			click_link 'Nuevo envío'
			wait_for_ajax
			dispatch_groups_containers = all('.dispatch-group-container')
			expect(dispatch_groups_containers.size).to be 3	
			within dispatch_groups_containers.last do 
				all('.save-dispatch').last.click
			end

			expect(page).to have_current_path(quotation_path(quotation))

			first('.collapse-dispatch-group-link').click
			sleep(1)
			first('.send-dispatch').click
			wait_for_ajax

			dispatch_groups_containers = all('.dispatch-group-container')
			expect(dispatch_groups_containers.size).to be 3	

			expect(dispatch_groups_containers[1]).to have_content('Despachado')
			expect(dispatch_groups_containers[2]).to have_content('En preparación')
			expect(first('.state-label')).to have_content('Despachos e Instalaciones')
			
			expect(page).to have_selector('.fake-destroy-dispatch-group')
		end

		it 'with partial reception', js: true do 
			create(:despachado)
			create(:por_instalar)
			quotation = create(:quotation_with_dispatched_state)

			expect(quotation.get_state).to eq 'Despachado'

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(page).to have_selector('.dispatch-group-container')
			dispatch_group_container = all('.dispatch-group-container')
			expect(dispatch_group_container.size).to be 2

			expect(dispatch_group_container.last).not_to have_selector('.input-product-quantity')
			expect(dispatch_group_container.last).to have_selector('.span-product-quantity')

			first('.select2-container').click
			first('.select2-search__field').set('Recepción parcial')

			within '.select2-results__options' do
				first('li', text: 'Recepción parcial').click
			end
			
			expect(dispatch_group_container.last).to have_selector('.input-product-quantity')
			expect(dispatch_group_container.last).not_to have_selector('.span-product-quantity')
			
			fill_in 'dispatch_group[product_in_dispatch_groups_attributes][0][quantity]', with: 0
			fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'observaciones de despacho'

			find('input[type="submit"]').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(all('.dispatch-group-container').last).to have_content('Por Instalar')

			expect(page).to have_selector('.products-pending-of-dispatch-container')
			within first('.products-pending-of-dispatch-container') do 
				products_in_dispatch = quotation.dispatch_groups
																				.first
																				.products_in_dispatch
																				.order(quantity: :asc)
				expect(page).to have_content("#{products_in_dispatch[0].product.name_and_sku} 1")
			end

			find('#products-tab').click
			sleep(1)
			expect(page).to have_selector('.products-container')
			expect(all('.products-container .product').size).to be 3

		end

		it 'change state to "peding reception"', js: true do 
			create(:en_preparacion)
			create(:por_instalar)
			dispatch_group = quotation.set_dispatch_group
			dispatch_group.update(state: create(:despachado))
			quotation.set_products_in_dispatch_group

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(all('.dispatch-group-container').last).to have_content('Despachado')

			first('.select2-container').click
			first('.select2-search__field').set('Pendiente de recepción')

			within '.select2-results__options' do
				first('li', text: 'Pendiente de recepción').click
			end

			fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'observaciones de recepción pendiente'

			find('input[type="submit"]').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(all('.dispatch-group-container').last).to have_content('En preparación')
			
			expect(dispatch_group.notes.count).to be 5
			expect(dispatch_group.notes.dispatch.count).to be 2
			expect(dispatch_group.notes.reception.count).to be 2
		end

		it 'change state from "to install" to installed without home program', js: true do 
			create(:por_instalar)
			create(:instalado)
			user = create(:manager_instalation_user)
			login_as(user, scope: :user)

			quotation = create(:quotation_with_to_install_state)

			expect(quotation.get_state).to eq 'Por instalar'
			expect(quotation.activation_confirm).to be false
			expect(user.role.name).to eq 'Manager Instalación'

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			
			within first('.dispatch-group-container') do 
				expect(page).to have_content('Por Instalar')
				expect(page).to have_selector('.top-save-instalation')
				fill_in 'dispatch_group[installation_date]', with: Date.today.strftime('%d/%m/%Y')
				click_button 'Enviar'
			end
			
			expect(page).to have_current_path(quotation_path(quotation))
			expect(first('.state-label')).to have_content('Instalado')
			expect(quotation.dispatch_groups.last.state.name).to eq 'Instalado'
			within first('.dispatch-group-container') do 
				expect(page).to have_content('Instalado')
				expect(page).not_to have_selector('.top-save-instalation')
			end
		end

		it 'change state from "to install" to installed with home program', js: true do 
			create(:por_instalar)
			create(:instalado)
			create(:por_activar)
			user = create(:manager_instalation_user)
			login_as(user, scope: :user)

			quotation = create(:quotation_with_to_install_state, activation_confirm: true)

			expect(quotation.get_state).to eq 'Por instalar'
			expect(quotation.activation_confirm).to be true
			expect(user.role.name).to eq 'Manager Instalación'

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			
			within first('.dispatch-group-container') do 
				expect(page).to have_content('Por Instalar')
				expect(page).to have_selector('.top-save-instalation')
				fill_in 'dispatch_group[installation_date]', with: Date.today.strftime('%d/%m/%Y')
				click_button 'Enviar'
			end

			expect(page).to have_current_path(quotation_path(quotation))
			expect(first('.state-label')).to have_content('Por activar')
			expect(quotation.dispatch_groups.last.state.name).to eq 'Instalado'
			within first('.dispatch-group-container') do 
				expect(page).to have_content('Instalado')
				expect(page).not_to have_selector('.top-save-instalation')
			end
		end

		it 'change state from "to install" to installed with observations', js: true do 
			create(:por_instalar)
			create(:instalacion_pendiente)
			user = create(:manager_instalation_user)
			login_as(user, scope: :user)

			quotation = create(:quotation_with_to_install_state)

			expect(quotation.get_state).to eq 'Por instalar'
			expect(quotation.activation_confirm).to be false
			expect(user.role.name).to eq 'Manager Instalación'

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(quotation.dispatch_groups.first.notes.count).to be 3
			within first('.dispatch-group-container') do 
				fill_in 'dispatch_group[installation_date]', with: Date.today.strftime('%d/%m/%Y')
				execute_script('$(".installation-confirm-option").parent().removeClass("radio-button")')
				expect(page).to have_content('Por Instalar')
				expect(page).to have_selector('.top-save-instalation')
				expect(all('.fake-radiobutton').count).to be 2
				expect(find('#dispatch_group_installation_confirm_confirm')).to be_checked
				expect(find('#dispatch_group_installation_confirm_pending')).not_to be_checked

				expect(page).not_to have_selector('textarea')
				expect(page).not_to have_selector('.backup-images')

				choose 'Instalación con observaciones'

				expect(page).to have_selector('textarea')
				expect(page).to have_selector('.backup-images')

				fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'observaciones de instalación'
				attach_file 'backup_images[]', "#{Rails.root}/spec/aux/105RR590.png", make_visible: true

				click_button 'Enviar'
			end
			expect(quotation.dispatch_groups.first.notes.count).to be 4
			expect(quotation.dispatch_groups.first.notes.second_to_last.image_notes.any?).to be true

			expect(page).to have_current_path(quotation_path(quotation))
			expect(first('.state-label')).to have_content('Instalación Pendiente')
			expect(quotation.dispatch_groups.last.state.name).to eq 'Instalación Pendiente'
			within first('.dispatch-group-container') do 
				expect(page).to have_content('Instalación Pendiente')
				expect(page).to have_selector('.top-save-instalation')
			end
		end
	end

	context 'for Project' do 
		let(:user){create(:project_user)}
		let(:product){create(:product_with_families)}

		before do 
			login_as(user, scope: :user)
			user.sale_channel.products << product
		end

		it 'add products to cart from catalog', js: true do
			business_unit = product.families.find_by(depth: 0)
			visit products_path(business_unit: business_unit.name)

			expect(page).to have_current_path(products_path(business_unit: business_unit.name))
			expect(page).to have_content(product.name)
			expect(page).to have_css("#items-in-cart", text: "0")

			expect(page).to have_selector('.fa-cart-plus')
			first('.fa-cart-plus').click
			wait_for_ajax
			expect(page).to have_content('Producto agregado con éxito')
			wait_for_ajax
			expect(page).to have_css("#items-in-cart", text: "1")
		end

		it 'add product to cart from product show', js: true do 
			visit product_path(sku: product.sku)

			expect(page).to have_current_path(product_path(sku: product.sku))
			expect(page).to have_content(product.name)
			expect(page).to have_css("#items-in-cart", text: "0")

			expect(page).to have_selector('#add-to-cart')
			expect(page).to have_button('Cotizar')
			click_button 'Cotizar'
			expect(page).to have_css("#items-in-cart", text: "1")
		end

		it 'increase product quantity without stock restrictions', js: true do 
			cart = create(:cart_with_product, user: user)
			expect(cart.products.count).to be 1
			product = cart.products.first
			product.update(stock: 1)
			expect(product.stock).to be 1

			visit cart_path
			expect(page).to have_current_path(cart_path)
			expect(page).to have_content(product.sku)
			expect(page).to have_selector('.cart-item-quantity')
			expect(first('.cart-item-quantity')).to have_content('1')

			expect(page).to have_selector("#btn-plus-#{product.id}")
			first("#btn-plus-#{product.id}").click
			wait_for_ajax
			expect(first('.cart-item-quantity')).to have_content('2')
		end

		it 'modify price to in cart products', js: true do 
			cart = create(:cart_with_product, user: user)
			expect(cart.products.count).to be 1
			product_in_cart = cart.products.first

			visit cart_path
			expect(page).to have_current_path(cart_path)
			expect(page).to have_selector("#cart-total-cost-#{cart.id}")
			expect(first("#cart-total-cost-#{cart.id}")).to have_content('699.990')

			expect(page).to have_selector('.cart-item-price-input')
			expect(page).to have_content('Precio de lista: $699.990')
			fill_in 'cart_items[0][price]', with: '500000'
			expect(first("#cart-total-cost-#{cart.id}")).to have_content('500.000')

			expect(page).to have_link('Continuar')
			expect(page).to have_selector('#continue-link')
			first('#continue-link').click

			expect(page).to have_current_path(new_quotation_path(currency: 'clp',
																													 exchange_rate: '1',
																													 exchange_rate_date: DateTime.current.strftime("%d/%m/%Y")))
			expect(page).to have_content("500.000")
		end

		it 'modify currency in cart', js: true do 
			cart = create(:cart_with_product, user: user)
			visit cart_path
			expect(page).to have_current_path(cart_path)

			expect(page).to have_link('Continuar', href: new_quotation_path(currency: "clp",
																																			exchange_rate: 1,
																																			exchange_rate_date: DateTime.current.strftime("%d/%m/%Y")))
			expect(page).to have_selector('#cart-currency-selector')
			select 'USD', from: 'cart-currency-selector'

			wait_for_ajax
			expect(page).to have_link('Continuar', href: "/quotations/new?currency=usd&exchange_rate=1&exchange_rate_date=#{DateTime.current.strftime("%d/%m/%Y")}")
			first('#continue-link').click
			expect(page).to have_current_path(new_quotation_path(currency: 'usd',
																													 exchange_rate: 1,
																													 exchange_rate_date: DateTime.current.strftime("%d/%m/%Y")))
		end

		it 'set any value between 0 and 100 to advance percent', js: true do 
			cart = create(:cart_with_product, user: user)
			visit cart_path
			expect(page).to have_current_path(cart_path)

			expect(page).not_to have_selector('#pay-50')
			expect(page).not_to have_selector('#pay-100')

			expect(page).to have_selector('#advance-percent-container')
			within find('#advance-percent-container') do 
				expect(page).to have_content('Porcentaje de adelanto')
				expect(page).to have_selector('#cart-advance-percent')
				expect(find('#cart-advance-percent').value).to eq cart.pay_percent.to_s
			end

			fill_in 'cart[pay_percent]', with: 44444
			expect(find('#cart-advance-percent').value).to eq '100'
			wait_for_ajax

			fill_in 'cart[pay_percent]', with: '-'
			expect(find('#cart-advance-percent').value).to eq '0'
			wait_for_ajax

			fill_in 'cart[pay_percent]', with: 44
			expect(find('#cart-advance-percent').value).to eq '44'

			wait_for_ajax
			sleep(2)
			expect(Cart.find(cart.id).pay_percent).to be 44
		end

		it '# create', js: true do 
			create(:cart_with_product, user: user)
			create(:en_negociacion)
			expect(Quotation.count).to be 0

			visit cart_path
			expect(page).to have_current_path(cart_path)

			expect(page).to have_selector('#cart-currency-selector')
			select 'USD', from: 'cart-currency-selector'
			expect(page).to have_selector('#continue-link')
			first('#continue-link').click

			expect(page).to have_current_path(new_quotation_path(currency: 'usd',
																													 exchange_rate: 1,
																													 exchange_rate_date: DateTime.current.strftime("%d/%m/%Y")))
			execute_script("$('#quotation_currency').attr('type', 'text');")
			expect(find('#quotation_currency').value).to eq 'usd'
			
			expect(all('.required').size).to be 1

			expect(page).to have_content('Nombre Proyecto')
			fill_in 'quotation[project_name]', with: 'Nombre proyecto'
			expect(page).to have_content('Nombre inmobiliaria')
			fill_in 'quotation[real_state_name]', with: 'Nombre inmobiliaria'
			expect(page).to have_content('Dirección Proyecto')
			fill_in 'quotation[dispatch_address]', with: 'Dirección proyecto'
			expect(page).to have_content('N°')
			fill_in 'quotation[dispatch_address_number]', with: '123'
			expect(page).to have_content('Comuna')

			expect(page).to have_content('Razón social')
			fill_in 'quotation[business_name]', with: 'Razón social'
			expect(page).to have_content('Giro comercial')
			fill_in 'quotation[business_sector]', with: 'Giro comercial'
			expect(page).to have_content('Rut empresa')
			fill_in 'quotation[business_rut]', with: '111111111'

			expect(page).to have_content('Centro de costo')
			select 'Web Shop', from: 'quotation[cost_center_id]'
			expect(page).to have_content('Fecha estimada Despacho')
			fill_in 'quotation[estimated_dispatch_date]', with: '12/12/2020'
			expect(page).to have_content('Fecha estimada Instalación')
			fill_in 'quotation[installation_date]', with: '12/12/2020'

			expect(page).to have_content('Observaciones')
			fill_in 'quotation[observations]', with: 'Observaciones'

			expect(page).to have_content('Información de contacto')
			expect(page).to have_content('Nombre')
			fill_in 'quotation[name]', with: 'nombre'
			expect(page).to have_content('Apellido paterno')
			fill_in 'quotation[lastname]', with: 'apellido'
			expect(page).to have_content('Apellido materno')
			fill_in 'quotation[second_lastname]', with: 'apellido 2'
			expect(page).to have_content('Teléfono')
			fill_in 'quotation[phone]', with: '12312'
			expect(page).to have_content('Correo electrónico')
			fill_in 'quotation[email]', with: 'mail@mail.com'
			expect(page).to have_content('Dirección Contacto')
			fill_in 'quotation[personal_address]', with: 'dirección de contacto'
			expect(page).to have_content('N°')
			fill_in 'quotation[personal_address_number]', with: '123'
			expect(page).to have_content('Depto')
			fill_in 'quotation[personal_dpto_number]', with: '123'
			expect(page).to have_content('Comuna')

			click_button 'Generar'

			expect(Quotation.count).to be 1
			expect(enqueued_jobs.count).to be 0
			quotation = Quotation.find_by(project_name: 'Nombre proyecto')
			expect(page).to have_current_path(quotation_resumen_path(quotation))
			expect(page).to have_content('¡Cotización Creada!')

			expect(quotation.code).to eq "#{quotation.try(:cost_center).try(:code)}-#{quotation.user.try(:miele_role).try(:code)}-#{quotation.try(:id)}-#{quotation.try(:project_name).try(:gsub, ' ', '_')}"
			expect(quotation.dispatch_address_number).to eq '123'
			expect(quotation.dispatch_address).to eq 'Dirección proyecto'
			expect(quotation.project_name).to eq 'Nombre proyecto'
			expect(quotation.real_state_name).to eq 'Nombre inmobiliaria'
			expect(quotation.document_type).to eq 'factura'
			expect(quotation.get_state).to eq 'En Negociación'
		end

		it 'show customer tab', js: true do 
			quotation = create(:quotation_for_project) 
			quotation.update(quotation_state: create(:en_preparacion))
			expect(quotation.channel).to eq 'Proyectos'
			expect(quotation.user).to eq user
			expect(quotation.get_state).to eq 'En preparación'

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(page).to have_link('Datos Proyecto', href: '#customer')
			click_link 'Datos Proyecto'

			expect(page).to have_selector('#customer')
			within find('#customer') do 
				expect(page).to have_content('Datos de contacto')
				expect(page).to have_content("Nombre #{quotation.name}")
				expect(page).to have_content("Apellido Paterno #{quotation.lastname}")
				expect(page).to have_content("Apellido Materno #{quotation.second_lastname}")
				expect(page).to have_content("Dirección personal #{quotation.personal_address} #{quotation.personal_address_number}")
				expect(page).to have_content("Nombre Proyecto #{quotation.project_name}")
				expect(page).to have_content("Correo #{quotation.email}")
				expect(page).to have_content("Teléfono #{quotation.phone}")

				expect(page).to have_content('Datos de Envío')
				expect(page).to have_content("Fecha estimada de Despachos #{quotation.estimated_dispatch_date.strftime("%d/%m/%Y")}")
				expect(page).to have_content("Dirección Proyecto #{quotation.dispatch_address}")
				expect(page).to have_content("N° #{quotation.dispatch_address_number}")
				expect(page).to have_content("Comuna #{quotation.dispatch_commune.name}")

				expect(page).to have_content('Datos de Instalación')
				expect(page).to have_content("Fecha estimada de Instalaciones #{quotation.installation_date.strftime("%d/%m/%Y")}")
				
				expect(page).to have_content('Datos de facturación')
				expect(page).to have_content("Razón social #{quotation.business_name}")
				expect(page).to have_content("Rut empresa #{quotation.business_rut}")
				expect(page).to have_content("Giro comercial #{quotation.business_sector}")
			end
		end

		it 'edit products', js: true do 
			quotation = create(:quotation_for_project, expiration_date: 30.days.from_now)
			days_to_expire = (quotation.expiration_date - quotation.created_at.to_date).to_i

			expect(quotation.products.count).to be 3
			expect(quotation.get_state).to eq 'En Negociación'
			expect(quotation.next_version).to be nil

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(page).to have_link('Productos', href: '#products')
			click_link 'Productos' 
			expect(page).to have_selector('#products')

			within find('#products') do 
				expect(page).to have_selector('.detail-quotation')
				expect(first('.detail-quotation')).to have_content('7.979.940,0')

				expect(page).to have_selector('.product-row')
				product_containers = all('.product-row')
				expect(product_containers.size).to be quotation.products.count

				within first('.product-row') do 
					expect(page).to have_selector('.cart-stepper-container')
					expect(page).to have_selector('.cart-stepper')
					first('.cart-stepper i').click

					expect(page).to have_selector('.item-price-input')
					fill_in 'price', with: '9999,12'
					expect(page).to have_content('19.998,24')
				end

				wait_for_ajax

				expect(first('.detail-quotation')).to have_content("7.299.948,24")
				expect(quotation.total).to be 7979940.0
				
			end
			
			expect(page).to have_button('Guardar')
			expect(page).not_to have_selector('.swal2-modal')
			click_button 'Guardar'
			
			expect(page).to have_selector('.swal2-modal')
			within first('.swal2-modal') do 
				expect(page).to have_content('Se creará una nueva versión de la cotización')
				expect(page).to have_content('¿Desea continuar?')
				first('.swal2-confirm').click
			end

			wait_for_ajax

			quotation = Quotation.find(quotation.id)
			expect(page).to have_current_path(quotation_path(quotation.next_version))
			click_link 'Productos' 
			expect(first('.detail-quotation')).to have_content("7.299.948,24")
			expect(quotation.next_version.total).to be 7299948.24
			expect(quotation.next_version.expiration_date).to eq days_to_expire.days.from_now.to_date
		end

		it 'edit customer data', js: true do 
			quotation = create(:quotation_for_project)
			expect(quotation.channel).to eq 'Proyectos'
			expect(quotation.get_state).to eq 'En Negociación'
			expect(quotation.next_version).to be nil

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			click_link 'Datos Proyecto'
			expect(page).to have_selector('#customer')
			within find('#customer') do 
				fill_in 'quotation[name]', with: 'Nuevo Nombre'
				fill_in 'quotation[lastname]', with: 'Nuevo Apellido Paterno'
				fill_in 'quotation[second_lastname]', with: 'Nuevo Apellido Materno'
				fill_in 'quotation[personal_address]', with: 'Nueva dirección'
				fill_in 'quotation[personal_address_number]', with: '876'
				fill_in 'quotation[project_name]', with: 'Nuevo nombre de proyecto'
				fill_in 'quotation[email]', with: 'nuevo@email.com'
				fill_in 'quotation[phone]', with: '99999999'
				
				page.execute_script("$('#quotation_estimated_dispatch_date').val('31/12/2022')")
				fill_in 'quotation[dispatch_address]', with: 'Nueva dirección de despacho'
				fill_in 'quotation[dispatch_address_number]', with: '678'
				
				page.execute_script("$('#quotation_installation_date').val('10/01/2023')")
				
				fill_in 'quotation[business_name]', with: 'Nueva razón social'
				fill_in 'quotation[business_sector]', with: 'Nuevo giro'
			end

			expect(page).to have_button('Guardar')
			click_button 'Guardar'
			
			wait_for_ajax
			
			expect(page).to have_current_path(quotation_path(quotation))
			click_link 'Datos Proyecto'
			within first('#customer') do 
				expect(first('input[name="quotation[name]"]').value).to eq 'Nuevo Nombre'
				expect(first('input[name="quotation[lastname]"]').value).to eq 'Nuevo Apellido Paterno'
				expect(first('input[name="quotation[second_lastname]"]').value).to eq 'Nuevo Apellido Materno'
				expect(first('input[name="quotation[personal_address]"]').value).to eq 'Nueva dirección'
				expect(first('input[name="quotation[personal_address_number]"]').value).to eq '876'
				expect(first('input[name="quotation[project_name]"]').value).to eq 'Nuevo nombre de proyecto'
				expect(first('input[name="quotation[email]"]').value).to eq 'nuevo@email.com'
				expect(first('input[name="quotation[phone]"]').value).to eq '99999999'
				expect(first('input[name="quotation[estimated_dispatch_date]"]').value).to eq '31/12/2022'
				expect(first('input[name="quotation[dispatch_address]"]').value).to eq 'Nueva dirección de despacho'
				expect(first('input[name="quotation[dispatch_address_number]"]').value).to eq '678'
				expect(first('input[name="quotation[installation_date]"]').value).to eq '10/01/2023'
				expect(first('input[name="quotation[business_name]"]').value).to eq 'Nueva razón social'
				expect(first('input[name="quotation[business_sector]"]').value).to eq 'Nuevo giro'
			end
		end

		it 'remove one product', js: true do 
			quotation = create(:quotation_for_project)
			expect(quotation.products.count).to be 3
			expect(quotation.get_state).to eq 'En Negociación'
			expect(quotation.next_version).to be nil

			first_product_name = quotation.quotation_products.first.name

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			click_link 'Productos'

			expect(first('.detail-quotation')).to have_content('7.979.940,0')

			expect(page).to have_selector('.remove-product')
			expect(all('.remove-product').count).to be quotation.products.count
			expect(page).to have_link('X', href: remove_quotation_product_path(quotation.quotation_products.first, in_current_version: true))

			click_link('X', href: remove_quotation_product_path(quotation.quotation_products.first, in_current_version: true))

			wait_for_ajax

			expect(page).to have_current_path(quotation_path(quotation))
			click_link 'Productos'
			wait_for_ajax
			expect(page).not_to have_content(first_product_name)
			expect(all('.remove-product').count).to be 2
			expect(quotation.products.count).to be 2

			sleep(1)
			expect(first('.detail-quotation')).to have_content('7.279.950,0')
			expect(quotation.total_cost).to be 7279950.0
		end

		it 'add new product', js: true do 
			quotation = create(:quotation_for_project)
			expect(quotation.products.count).to be 3
			expect(quotation.next_version).to be nil

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(Product.find_by(sku: 'new-sku')).to be nil

			click_link 'Productos'

			within find('#products') do 
				expect(all('.product-row').count).to be 3

				expect(page).not_to have_selector('#add-product-form')
				expect(page).to have_link('Nuevo Producto', href: '#add-product-form')
				click_link 'Nuevo Producto'

				wait_for_ajax

				expect(page).to have_selector('#add-product-form')

				within first('#add-product-form') do 
					expect(page).to have_content('Nombre')
					fill_in 'quotation_product[name]', with: 'nuevo producto'
					expect(page).to have_content('TNR')
					fill_in 'quotation_product[sku]', with: 'new-sku'
					expect(page).to have_content('Cantidad')
					fill_in 'quotation_product[quantity]', with: '3'
					expect(page).to have_content('Precio')
					fill_in 'quotation_product[price]', with: '9999,12'
				end
			end

			expect(page).to have_button('Agregar Producto')
			click_button 'Agregar Producto'

			expect(page).to have_current_path(quotation_path(quotation))
			expect(all('.product-row').count).to be 4
			expect(page).to have_content('nuevo producto')
			expect(page).to have_content('new-sku')
			expect(first('.detail-quotation')).to have_content('8.009.937,36')

			new_product = Product.find_by(sku: 'new-sku')
			expect(new_product).not_to be nil
			expect(new_product.only_for_project).to be true
			expect(new_product.name).to eq 'nuevo producto'
			expect(new_product.price).to be 9999.12
		end

		it 'add existing product', js: true do 
			quotation = create(:quotation_for_project)
			expect(quotation.products.count).to be 3
			product = create(:product, sku: 'new-product', name: 'Nuevo producto')

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(Product.find_by(sku: 'new-product')).to eq product

			click_link 'Productos'
			within find('#products') do 
				expect(all('.product-row').count).to be 3

				click_link 'Nuevo Producto'

				wait_for_ajax


				within first('#add-product-form') do 
					expect(page).to have_content('Nombre')
					fill_in 'quotation_product[name]', with: 'nombre producto'
					expect(page).to have_content('TNR')
					fill_in 'quotation_product[sku]', with: 'new-product'
					expect(page).to have_content('Cantidad')
					fill_in 'quotation_product[quantity]', with: '3'
					expect(page).to have_content('Precio')
					fill_in 'quotation_product[price]', with: '9999,12'

					expect(first('input[name="quotation_product[name]"]').value).not_to eq 'nombre producto'
					expect(first('input[name="quotation_product[name]"]').value).to eq product.name

					click_button 'Agregar Producto'
				end
			end

			wait_for_ajax
			expect(page).to have_current_path(quotation_path(quotation))
			
			expect(all('.product-row').count).to be 4
			expect(page).to have_content(product.name)
			expect(page).to have_content('new-product')
			expect(first('.detail-quotation')).to have_content('8.009.937,36')

			expect(Product.where(sku: 'new-product').count).to be 1
		end

		it 'add product present in current quotation', js: true do 
			quotation = create(:quotation_for_project)
			expect(quotation.products.count).to be 3
			item = quotation.quotation_products.last
			expect(quotation.next_version).to be nil

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			click_link 'Productos'

			within find('#products') do 
				click_link 'Nuevo Producto'

				wait_for_ajax

				within first('#add-product-form') do 
					expect(page).to have_content('Nombre')
					fill_in 'quotation_product[name]', with: 'producto existente sin saberlo'
					expect(page).to have_content('TNR')
					fill_in 'quotation_product[sku]', with: item.sku
				end
			end

			click_link 'Productos' # Para gatillar el onchange
			wait_for_ajax
				
			expect(first('input[name="quotation_product[name]"]').value).not_to eq 'producto existente sin saberlo'
			expect(first('input[name="quotation_product[name]"]').value).to eq item.name
			expect(first('input[name="quotation_product[price]"]').value).to eq '699.990,00'
			expect(first('input[name="quotation_product[quantity]"]').value).to eq item.quantity.to_s

			click_button 'Agregar Producto'

			wait_for_ajax

			expect(page).to have_current_path(quotation_path(quotation))
			expect(all('.product-row').count).to be 3
		end

		it 'show previous versions', js: true do 
			quotation = create(:quotation_with_later_versions)
			expect(quotation.next_version).not_to be nil
			last_version = quotation.last_version
			expect(last_version.next_version).to be nil

			visit(quotation_path(last_version))
			expect(page).to have_current_path(quotation_path(last_version))

			expect(page).to have_selector('.versions-alert')
			within first('.versions-alert') do 
				expect(page).to have_content("Última modificación el #{last_version.created_at.strftime('%d/%m/%Y %H:%M')}")
				expect(page).to have_link('Ver historial de versiones', href: '#versions-sidebar')
			end
			expect(page).not_to have_selector('#versions-sidebar')
			click_link 'Ver historial de versiones'
			
			expect(page).to have_selector('#versions-sidebar')
			within find('#versions-sidebar') do 
				expect(page).to have_content('Historial de versiones')
				expect(page).to have_selector('.version-container')

				version_containers = all('.version-container')
				expect(version_containers.size).to be 3

				within version_containers[0] do 
					expect(page).to have_content(last_version.created_at.strftime('%d/%m/%Y %H:%M'))
					expect(page).to have_content('7.279.950,0')
					expect(page).to have_content("Productos: #{last_version.products.count}")
					expect(page).to have_content('Vista actual')
				end

				within version_containers[1] do 
					expect(page).to have_content(quotation.next_version.created_at.strftime('%d/%m/%Y %H:%M'))
					expect(page).to have_content('7.279.950,0')
					expect(page).to have_content("Productos: #{quotation.next_version.products.count}")
				end

				within version_containers[2] do 
					expect(page).to have_content(quotation.created_at.strftime('%d/%m/%Y %H:%M'))
					expect(page).to have_content('7.979.940,0')
					expect(page).to have_content("Productos: #{quotation.products.count}")
				end

				version_containers[1].click
			end

			wait_for_ajax

			expect(page).to have_current_path(quotation_path(quotation.next_version))
			click_link 'Productos'
			wait_for_ajax
			expect(page).not_to have_selector('#save-product-changes')
		end

		it 'not show previous versions on index', js: true do 
			quotation = create(:quotation_with_later_versions)
			expect(Quotation.count).to be 3
			expect(Quotation.where(next_version: nil).count).to be 1
			expect(quotation.code).to eq quotation.next_version.code

			visit quotations_path
			expect(page).to have_current_path(quotations_path)
			expect(page).to have_selector('.quotation-card')
			expect(all('.quotation-card').count).to be 1
			expect(page).to have_content(Quotation.find_by(next_version: nil).code)
		end

		it 'set dispatch configurations', js: true do 
			create(:en_preparacion)
			create(:dispatch_to_validate_state)
			quotation = create(:quotation_for_project, user: user)
			quotation.update(quotation_state: create(:en_curso))
			quotation.set_dispatch_group
			quotation.set_products_in_dispatch_group

			expect(quotation.get_state).to eq 'En curso'
			expect(user.is_project?).to be true
			expect(quotation.products.count).to be 3
			expect(quotation.dispatch_groups.count).to be 1
			expect(quotation.dispatch_groups.first.state.name).to eq 'En preparación'

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			expect(page).not_to have_selector('.dispatch-group-container')
			expect(page).to have_link('Configuración de Despacho')
			click_link 'Configuración de Despacho'

			expect(quotation.dispatch_instructions_files.count).to be 0
			expect(page).to have_selector('#dispatch-configuration')
			within find('#dispatch-configuration') do 
				expect(page).to have_content('Agregar guías de envíos')
				expect(page).to have_selector('.file-field')
				attach_file 'quotation[dispatch_instruction_files][]', "#{Rails.root}/spec/aux/pdf_prueba.pdf", make_visible: true
				expect(page).to have_button 'Guardar'
				
				click_button 'Guardar'
			end

			expect(quotation.dispatch_instructions_files.count).to be 1
			expect(page).to have_current_path(quotation_path(quotation))
			click_link 'Configuración de Despacho'
			within find('#dispatch-configuration') do 
				expect(page).to have_link('pdf_prueba')
			end
		end

		it 'send dispatch configuration notification to finances roles', js: true do 
			create(:en_preparacion)
			quotation = create(:quotation_for_project, user: user)
			quotation.update(quotation_state: create(:en_curso))
			
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_link('Configuración de Despacho')
			click_link 'Configuración de Despacho'

			within find('#dispatch-configuration') do 
				expect(page).to have_link('Enviar', href: send_dispatch_configuration_alert_path(quotation))
				click_link 'Enviar'
			end
			expect(enqueued_jobs.size).to be 1
			expect(enqueued_jobs.first[:queue]).to eq 'mailers'
			expect(enqueued_jobs.first[:args][1]).to eq 'dispatch_configuration_alert'
			
			expect(page).to have_current_path(quotation_path(quotation))
		end

		it 'download an excel with quotations details', js: true do 
			Capybara.current_driver = :webkit
			quotation_1 = create(:quotation_for_project, user: user)
			quotation_2 = create(:quotation_for_project, user: user)
			quotation_3 = create(:quotation_for_project, user: user)

			visit quotations_path
			expect(page).to have_current_path(quotations_path)
			expect(page).to have_selector('.quotation-card')
			expect(all('.quotation-card').size).to be 3

			expect(page).to have_button('Descargar proyectos')
			click_button 'Descargar proyectos'

			expect(response_headers['Content-Disposition']).to eq "attachment; filename=\"cotizaciones_proyectos_#{Date.today.strftime("%d/%m/%Y")}.xlsx\""
		end

		it 'download pdf', js: true do 
			quotation = create(:quotation_with_later_versions)

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			click_link 'Ver historial de versiones'
			execute_script('$("#versions-sidebar").addClass("show-sidebar")')
			expect(page).to have_selector('#versions-sidebar')

			within find('#versions-sidebar') do 
				version_containers = all('.version-container')
				expect(version_containers.size).to be 3

				expect(page).to have_selector('.download-pdf')
				expect(all('.download-pdf').count).to be 3

				within first('.version-container') do 
					expect(page).to have_link('Descargar', href: quotation_path(quotation.last_version, format: :pdf))
					click_link 'Descargar'
				end
			end

			# expect(response_headers['Content-Disposition']).to eq "attachment; filename=\"Cotización_proyecto_#{quotation.code}.pdf\""
		end
	end
end