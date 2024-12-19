require 'rails_helper'
describe 'Quotation Flow Project', type: :feature do 
	include ActiveJob::TestHelper
	let(:project_user){create(:project_user)}

	context 'Manage' do
		before do 
			login_as(project_user, scope: :user)
			create(:cost_center)
			create(:providencia)
			create(:ingresada)
			create(:cerrado)
			create(:en_negociacion)
			create(:por_activar)
			create(:productos_activados)
			create(:en_curso)
			create(:cancelada)
			ActionMailer::Base.deliveries = []
			clear_enqueued_jobs
		end

		after do 
			ActionMailer::Base.deliveries = []
		end

		it 'download project template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#project-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_project.xlsx"'
			Capybara.use_default_driver
		end

		it 'create quotation from excel and inspect', js: true do 
			Timecop.freeze(Date.new(2020, 07, 01))
			product = create(:product)
			product_2 = create(:product_2)
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('quotations_project_load', Rails.root + "spec/aux/plantilla_project_1.xlsx", make_visible: true)
			first('#load-quotations-project').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Cotizaciones de Project cargados con éxito.')
			expect(Quotation.all.size).to eq 1
			expect(Quotation.last.observations).to eq 'Condominio'
			expect(Quotation.last.quotation_products.size).to eq 2
			expect(Quotation.last.get_state).to eq 'Ingresada'
			expect(ActionMailer::Base.deliveries.count).to eq 0

			visit quotation_path(Quotation.last)
			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Ingresada')
			expect(page).to have_selector('#finish-quotation')
			expect(page).to have_content('Fecha 01/07/2020 Centro Costo 36 Nombre Completo Manager Proyectos Materno Rol Manager Proyectos Correo Contacto project@test.net Teléfono Contacto 987654321')
			expect(page).to have_content('Lavadora 8 Kg WCE 660 TwinDos WiFi 10545430 $ 1.449.990,0 30,0')
			expect(page).to have_content('Máquina de Café CM5300 105RR590 $ 699.990,0 20,0')
			expect(page).to have_content('Total Neto 50,0')

			click_link('Datos Proyecto')
			expect(first('input[name="quotation[name]"]').value).to eq 'Oferus'
			expect(first('input[name="quotation[lastname]"]').value).to eq 'Prueba'
			expect(first('input[name="quotation[second_lastname]"]').value).to eq 'Test'

			Timecop.return
		end

		it 'create lead from excel and inspect', js: true do 
			create(:lead_state)
			Timecop.freeze(Date.new(2020, 07, 01))
			product = create(:product)
			product_2 = create(:product_2)
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('quotations_project_load', Rails.root + "spec/aux/plantilla_project_3.xlsx", make_visible: true)
			first('#load-quotations-project').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Cotizaciones de Project cargados con éxito.')
			expect(Quotation.all.size).to eq 1
			expect(Quotation.last.quotation_products.size).to eq 2
			expect(Quotation.last.get_state).to eq 'Lead'
			expect(ActionMailer::Base.deliveries.count).to eq 0

			visit quotation_path(Quotation.last)
			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Lead')
			expect(page).to have_content('Fecha 01/07/2020 Centro Costo 36 Nombre Completo Manager Proyectos Materno Rol Manager Proyectos Correo Contacto project@test.net Teléfono Contacto 987654321')
			expect(page).to have_content('Lavadora 8 Kg WCE 660 TwinDos WiFi 10545430 2 $ 1.449.990,0 15,0 30,0')
			expect(page).to have_content('Máquina de Café CM5300 105RR590 1 $ 699.990,0 20,0 20,0')
			expect(page).to have_content('Total Neto 50,0')

			click_link('Datos Proyecto')
			sleep(2)
			expect(page).to have_content('Datos de contacto Nombre Oferus Apellido Paterno Prueba Apellido Materno Test Dirección personal Los misioneros 1973 Nombre Proyecto Ofertus Correo prueba@garagelabs.cl Teléfono 987654321')

			Timecop.return
		end

		it 'update quotation from excel and delete product from line items', js: true do 
			Timecop.freeze(Date.new(2020, 07, 01))
			quotation = create(:quotation_dispatch_retirement, sale_channel: SaleChannel.last, currency: :uf, correlative: '1000', user: project_user)
			quotation.to_state('Ingresada')
			expect(Quotation.last.quotation_products.size).to eq 2
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('quotations_project_load', Rails.root + "spec/aux/plantilla_project_2.xlsx", make_visible: true)
			first('#load-quotations-project').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Cotizaciones de Project cargados con éxito.')
			expect(Quotation.all.size).to eq 1
			expect(Quotation.last.quotation_products.size).to eq 1
			expect(Quotation.last.get_state).to eq 'Ingresada'
			expect(enqueued_jobs.size).to be 1
			expect(Quotation.last.quotation_products.last.price).to eq 15
			expect(Quotation.last.dispatch_address).to eq 'Los navegaos 123'
			Timecop.return
		end

		it 'put in negotiation and rollback', js: true do 
			skip 'Business logic was changed'
			create(:quotation_retirement, sale_channel: SaleChannel.last, currency: :clp, user: project_user)
			Quotation.last.to_state('En Negociación')
			ActionMailer::Base.deliveries = []

			visit quotation_path(Quotation.last)
			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('En Negociación')
			expect(page).to have_selector('#finish-quotation')
			expect(page).to have_selector('#negotiation-quotation')
			expect(page).to have_selector('#close-quotation')

			first('#negotiation-quotation').click

			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('En Negociación')
			expect(ActionMailer::Base.deliveries.count).to eq 0

			first('#negotiation-quotation').click

			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('En Negociación')
			expect(ActionMailer::Base.deliveries.count).to eq 0
		end

		it 'upload backup files', js: true do 
			create(:quotation_retirement, sale_channel: SaleChannel.last, currency: :clp, user: project_user, activation_confirm: true)
			Quotation.last.to_state('Ingresada')
			ActionMailer::Base.deliveries = []

			visit quotation_path(Quotation.last)
			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Ingresada')
			click_link('Activación')
			sleep(2)

			attach_file('payment_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			first('#send-billing-documents').click

			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Ingresada')
			expect(page).to have_content('Documentos subidos con éxito.')
			expect(Quotation.last.payment_documents.size).to eq 1
		end

		it 'close quotation without home program', js: true do 
			skip 'Business logic was changed'
			create(:quotation_retirement, sale_channel: SaleChannel.last, currency: :clp, user: project_user, activation_confirm: false)
			Quotation.last.to_state('Ingresada')
			ActionMailer::Base.deliveries = []

			visit quotation_path(Quotation.last)
			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Ingresada')
			expect(page).to have_selector('#finish-quotation')
			expect(page).to have_selector('#close-quotation')
			first('#close-quotation').click

			visit quotation_path(Quotation.last)
			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Cerrado')
		end

		it 'close quotation with home program', js: true do 
			skip 'Business logic was changed'
			create(:quotation_retirement, sale_channel: SaleChannel.last, currency: :clp, user: project_user, activation_confirm: true)
			Quotation.last.to_state('Ingresada')

			visit quotation_path(Quotation.last)
			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Ingresada')
			expect(page).to have_selector('#finish-quotation')
			expect(page).to have_selector('#negotiation-quotation')
			expect(page).to have_selector('#close-quotation')
			first('#close-quotation').click

			visit quotation_path(Quotation.last)
			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Por activar')

			click_link('Home Program')
			sleep(2)

			fill_in 'home_program_observation', with: 'Ningun problema master'
			first('#send-home-program').click

			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Productos activados')

			click_link('Home Program')
			sleep(2)
			expect(page).to have_content('Observación de '+project_user.fullname+' el día '+Date.today.strftime("%d/%m/%Y"))
			expect(page).to have_content('Ningun problema master')
			expect(enqueued_jobs.count).to be 1

		end

		it 'cancel quotation', js: true do 
			skip 'Business logic was changed'
			create(:quotation_retirement, sale_channel: SaleChannel.last, currency: :clp, user: project_user, activation_confirm: false)
			Quotation.last.to_state('Ingresada')
			ActionMailer::Base.deliveries = []

			visit quotation_path(Quotation.last)
			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Ingresada')
			expect(page).to have_selector('#finish-quotation')
			expect(page).to have_selector('#negotiation-quotation')
			expect(page).to have_selector('#close-quotation')
			first('#finish-quotation').click
			first('.swal2-confirm').click

			visit quotation_path(Quotation.last)
			expect(page).to have_current_path(quotation_path(Quotation.last))
			expect(page).to have_content('Cancelada')
		end
	end
end