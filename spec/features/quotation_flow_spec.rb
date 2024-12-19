require 'rails_helper'
describe 'Quotation Flow', type: :feature do 
	let(:user){create(:user)}
	let(:finance_user){create(:finance_user)}
	let(:manager_finance_user){create(:manager_finance_user)}
	let(:manager_user){create(:manager_user)}
	let(:manager_dispatch_user){create(:manager_dispatch_user)}
	let(:manager_instalation_user){create(:manager_instalation_user)}
	let(:seller_user){create(:mca_seller_user)}
	let(:retail_user){create(:retail_user)}

	context 'Activation' do
		before do 
			login_as(user, scope: :user)
			create(:enviada)
			create(:cerrado)
			create(:en_curso)
			ActionMailer::Base.deliveries = []
		end

		after do 
			ActionMailer::Base.deliveries = []
		end


		it 'by admin, only retirement save changes', js: true do 
			quotation = create(:quotation_retirement)
			ActionMailer::Base.deliveries = []
			login_as(user, scope: :user)
			visit quotations_path
			expect(page).to have_current_path(quotations_path)
			first('.show-eye').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Los productos sólo pueden ser retirados en tienda cuando ya se canceló el total de la cotización.')
			# registro un pago parcial
			first('.activation-tnr').click
			fill_in 'quotation_v1', with: '21309123'
			attach_file('billing_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			fill_in 'payment_ammount', with: '600000'
			expect(page).to have_button("Entregado", disabled: true)
			first('#save-activation').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cambios guardados con éxito.')
			expect(quotation.payments.size).to eq 1
			#registro el saldo del pago
			expect(page).to have_button('Entregado', disabled: false)
			fill_in 'payment_ammount', with: '99990'
			within '#payment-type-activation' do
				find('.select2-container').click
			end
			find(".select2-search__field").set('Trans')

			within ".select2-results__options" do
				find('li', text: 'Pago con Transferencia').click
			end
			expect(page).to have_button("Entregado", disabled: false)
			first('#save-activation').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cambios guardados con éxito.')
			expect(quotation.payments.size).to eq 2
			expect(page).to have_button("Entregado", disabled: false)
			# checkeo pago
			click_link('Finanzas')
			sleep(2)
			expect(page).to have_content('Tipo de Pago Transferencia Monto Pagado CLP 99.990')
			expect(page).to have_content('Tipo de Pago Efectivo Monto Pagado CLP 600.000')
		end

		it 'by admin, only retirement active that and update', js: true do 
			quotation = create(:quotation_retirement)
			ActionMailer::Base.deliveries = []
			login_as(user, scope: :user)
			visit quotations_path
			expect(page).to have_current_path(quotations_path)
			first('.show-eye').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Los productos sólo pueden ser retirados en tienda cuando ya se canceló el total de la cotización.')
			# registro un pago parcial
			first('.activation-tnr').click
			#
			fill_in 'payment_ammount', with: '600000'
			first('.activation-msg').click
			expect(page).to have_button("Entregado", disabled: false)
			first('#send-activation').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cerrado')
			expect(page).to have_content('Activación realizada con éxito')
			expect(quotation.payments.size).to eq 1
			click_link('Finanzas')
			sleep(2)
			expect(page).to have_content('Tipo de Pago Efectivo Monto Pagado CLP 600.000')
			click_link('Activación')
			sleep(2)
			fill_in 'quotation_v1', with: '21309123'
			expect(page).not_to have_selector('#send-activation')
			first('#save-activation').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cambios guardados con éxito.')
			expect(Quotation.last.v1).to eq '21309123'
		end

		it 'by admin, only retirement active full ammount of total', js: true do 
			quotation = create(:quotation_retirement)
			ActionMailer::Base.deliveries = []
			login_as(user, scope: :user)
			visit quotations_path
			expect(page).to have_current_path(quotations_path)
			first('.show-eye').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Los productos sólo pueden ser retirados en tienda cuando ya se canceló el total de la cotización.')
			# registro un pago parcial
			first('.activation-tnr').click
			#
			fill_in 'payment_ammount', with: '699990'
			first('.activation-msg').click
			expect(page).to have_button("Entregado", disabled: false)
			first('#send-activation').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cerrado')
			expect(page).to have_content('Activación realizada con éxito')
			expect(quotation.payments.size).to eq 1
			click_link('Finanzas')
			sleep(2)
			expect(page).to have_content('Tipo de Pago Efectivo Monto Pagado CLP 699.990')
			click_link('Activación')
			sleep(2)
			expect(page).not_to have_selector('#payment_ammount')
			fill_in 'quotation_v1', with: '21309123'
			expect(page).not_to have_selector('#send-activation')
			first('#save-activation').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cambios guardados con éxito.')
			expect(Quotation.last.v1).to eq '21309123'
		end

		it 'by admin, only retirement and delivered', js: true do 
			quotation = create(:quotation_retirement)
			ActionMailer::Base.deliveries = []
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			Product.last.update(stock_break: false)
			expect(Product.last.stock).to eq 30
			expect(page).to have_content('Enviada')
			expect(page).to have_content('Los productos sólo pueden ser retirados en tienda cuando ya se canceló el total de la cotización.')
			first('.activation-tnr').click
			fill_in 'payment_ammount', with: '699990'
			fill_in 'quotation_v1', with: '21309123'
			attach_file('billing_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			sleep(1)
			first('#send-activation').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cerrado')
			expect(page).to have_content('Activación realizada con éxito')
			expect(quotation.payments.size).to eq 1
			expect(Product.last.stock).to eq 29
		end

		it 'by admin, only dispatch', js: true do 
			quotation = create(:quotation_dispatch)
			ActionMailer::Base.deliveries = []
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Enviada')
			Product.last.update(stock_break: false)
			expect(Product.last.stock).to eq 30
			expect(page).not_to have_content('Los productos sólo pueden ser retirados en tienda cuando ya se canceló el total de la cotización.')
			first('.activation-tnr').click
			fill_in 'payment_ammount', with: '699990'
			attach_file('billing_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			attach_file('sell_note_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			first('#send-activation').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Activación realizada con éxito')
			expect(page).to have_content('En curso')
			expect(Product.last.stock).to eq 29
		end

		it 'by admin, dispatch+retirement', js: true do 
			quotation = create(:quotation_dispatch_retirement)
			ActionMailer::Base.deliveries = []
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Enviada')
			expect(page).to have_content('Los productos sólo pueden ser retirados en tienda cuando ya se canceló el total de la cotización.')
			first('.activation-tnr').click
			fill_in 'quotation_v1', with: '21309123'
			fill_in 'payment_ammount', with: '1399980'
			attach_file('billing_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			attach_file('sell_note_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			sleep(1)
			first('#send-activation').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Activación realizada con éxito')
			expect(page).to have_content('En curso')
		end

		it 'cancel quotation', js: true do 
			create(:cancelada)
			quotation = create(:quotation_dispatch_retirement)
			ActionMailer::Base.deliveries = []
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Enviada')
			#terminar cotización
			first('#finish-quotation').click
			click_button('Sí')
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cancelada')
			expect(page).to have_content('Cotización cancelada con éxito')
		end

		it 'put in progress quotation and cancel other one for not enough stock', js: true do 
			quotation = create(:quotation_dispatch)
			quotation_2 = create(:quotation_dispatch)
			create(:cancelada)
			Product.last.update(stock: 1, stock_break: false)
			ActionMailer::Base.deliveries = []
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Enviada')
			expect(Product.last.stock).to eq 1
			expect(page).not_to have_content('Los productos sólo pueden ser retirados en tienda cuando ya se canceló el total de la cotización.')
			first('.activation-tnr').click
			fill_in 'payment_ammount', with: '699990'
			attach_file('billing_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			attach_file('sell_note_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			first('#send-activation').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Activación realizada con éxito')
			expect(page).to have_content('En curso')
			expect(Product.last.stock).to eq 0
			expect(Quotation.last.get_state).to eq 'Cancelada'
		end
	end

	context 'Seller' do
		before do
			login_as(seller_user, scope: :user)
			create(:enviada)			
			create(:productos_activados)
		end

		it 'Seller reactivate quotation', js: true do 
			Timecop.freeze(Date.new(2020, 04, 01))
			expired = create(:vencida)
			quotation = create(:quotation_dispatch_retirement)
			quotation.to_state('Vencida')
			quotation.quotation_products.find_by(dispatch: false).product.update(stock: 0)
			QuotationProduct.first.product.product_discount = create(:product_discount)

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Vencida')
			click_link('Productos')
			sleep(1)
			expect(page).to have_content('Total $ 1.399.980')
			first('#reactivate-quotation').click
			click_button('Aceptar')

			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Enviada')
			expect(page).to have_content('Cotización reactivada con éxito.')
			expect(page).to have_content('TNR 105RR590 - Máquina de Café CM5300')
			click_link('Productos')
			sleep(1)
			expect(page).to have_content('Despacho + Instalación $ 5.900')
			expect(page).to have_content('Total $ 705.890')
			expect(Quotation.last.quotation_document).not_to eq nil
			Timecop.return
		end

		it 'activate home program', js: true do
			home_program_activate = create(:por_activar)
			quotation = create(:quotation_dispatch_retirement, user: seller_user)
			quotation.update(quotation_state: home_program_activate)
			ActionMailer::Base.deliveries = []
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Por activar')
			first('#home-program-tab').click
			sleep(2)
			fill_in 'home_program_observation', with: 'Ningun problema master'
			first('#send-home-program').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Productos activados')

			click_link('Home Program')
			sleep(2)
			expect(page).to have_content('Observación de '+seller_user.fullname+' el día '+Date.today.strftime("%d/%m/%Y"))
			expect(page).to have_content('Ningun problema master')
		end

		it 'load billing document after first activation', js: true do 
			in_progress = create(:en_curso)
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: in_progress)
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))

			click_link('Activación')
			sleep(1)
			attach_file('payment_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			attach_file('billing_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			first('#send-billing-documents').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('En curso')
			expect(page).to have_content('Documentos subidos con éxito.')
			expect(quotation.payment_documents.size).to eq 1
			expect(quotation.billing_documents.size).to eq 1
		end
	end

	context 'Finance approval' do
		before do 
			login_as(finance_user, scope: :user)
			create(:enviada)
			create(:pendiente)
			create(:en_curso)
			create(:en_preparacion)
			ActionMailer::Base.deliveries = []
		end

		it 'saving changes', js: true do 
			in_progress = create(:en_curso)
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: in_progress)
			ActionMailer::Base.deliveries = []
			
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('En curso')
			fill_in 'quotation_so_code', with: 'RDD123123'
			first('#paid_50').click
			expect(page).to have_css("#send-info-billing:disabled")
			first('#save_changes').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_css("#send-info-billing:disabled")
			expect(page).to have_content('Cotización actualizada con éxito')
			expect(page).to have_content('Pendiente')
		end

		it 'cancel quotation', js: true do 
			create(:cancelada)
			in_progress = create(:en_curso)
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: in_progress)
			ActionMailer::Base.deliveries = []
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('En curso')
			expect(Product.last.stock).to eq 30
			Product.last.update(stock_break: false)
			first('#finish-quotation').click
			click_button('Sí')
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cancelada')
			expect(page).to have_content('Cotización cancelada con éxito')
			# se devuelve el stock comprometido
			expect(Product.last.stock).to eq 31
		end

		it 'sending info and finishing quotation', js: true do 
			in_progress = create(:en_curso)
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: in_progress)
			ActionMailer::Base.deliveries = []

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			
			expect(page).to have_content('En curso')
			fill_in 'quotation_so_code', with: 'RDD123123'
			first('#paid_100').click
			expect(page).to have_css("#send-info-billing:enabled")
			first('#send-info-billing').click
			
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cotización actualizada con éxito')
			expect(page).to have_content('En preparación')
		end

		it 'can\'t approve when payments not come from webpay' , js: true do 
			in_progress = create(:en_curso)
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: in_progress)
			ActionMailer::Base.deliveries = []
			create(:cash_payment, quotation: quotation)
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('En curso')
			fill_in 'quotation_so_code', with: 'RDD123123'
			first('#paid_100').click
			expect(page).to have_css("#send-info-billing:disabled")
		end

		it 'activate retail quotation ready', js: true do 
			quotation = create(:retail_quotation)
			Product.first.retail_products << create(:retail_product, retail: Retail.first, tnr: 'ABC123')
			quotation.to_state('En curso')
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			fill_in 'so_code', with: 'ABC123'
			first('#send-finance-activation-ready').click
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('En preparación')
			click_link('Finanzas')
			expect(page).to have_content('ABC123')
			expect(page).to have_content('OC Lista')
		end

		it 'activate retail quotation with update stock', js: true do 
			quotation = create(:retail_quotation)
			Product.first.retail_products << create(:retail_product, retail: Retail.first, tnr: 'ABC123')
			quotation.to_state('En curso')
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			fill_in 'so_code', with: 'ABC123'
			first('#oc_updated').click
			sleep(1)
			fill_in 'finance_observations', with: 'le cambie unas cantidades'
			first('#send-finance-activation-updated').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('En preparación')
			click_link('Finanzas')
			sleep(1)
			first('#finances-tab').click
			expect(page).to have_selector("input[value='ABC123']")
			expect(page).to have_content('OC Lista')
			expect(page).to have_content('Observación de Finance Test')
			expect(page).to have_content('le cambie unas cantidades')
		end

		it 'change quantity by stock', js: true do 
			quotation = create(:retail_quotation)
			Product.first.retail_products << create(:retail_product, retail: Retail.first, tnr: 'ABC123')
			quotation.to_state('En curso')
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			click_link('Activación')
			sleep(1)
			expect(page).to have_content('Sub Total: $ 699.990')
			expect(page).to have_content('Despacho $ 20.000')
			expect(page).to have_content('Total Neto $ 719.990')
			fill_in 'quotation_product_1_quantity', with: '3'
			first('#save_quantities').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cantidades actualizadas con éxito.')
			click_link('Activación')
			sleep(1)
			expect(page).to have_content('Sub Total: $ 2.099.970')
			expect(page).to have_content('Despacho $ 20.000')
			expect(page).to have_content('Total Neto $ 2.119.970')
		end
	end

	context 'Manager Finance approval' do
	 	before do 
			login_as(manager_finance_user, scope: :user)
			create(:enviada)
			create(:pendiente)
			create(:en_curso)
			create(:en_preparacion)
			ActionMailer::Base.deliveries = []
		end

		it 'approve when payments not come from webpay' , js: true do 
			in_progress = create(:en_curso)
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: in_progress)
			ActionMailer::Base.deliveries = []
			create(:cash_payment, quotation: quotation)
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('En curso')
			fill_in 'quotation_so_code', with: 'RDD123123'
			first('#paid_100').click
			first('#send-info-billing').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Cotización actualizada con éxito')
			expect(page).to have_content('En preparación')
		end
	end

	context 'Dispatch approval' do
		before do 
			login_as(manager_dispatch_user, scope: :user)
			create(:enviada)
			create(:despachado)
			ActionMailer::Base.deliveries = []
		end

		it 'approve only dispatch', js: true do 
			in_preparation = create(:en_preparacion)
			quotation = create(:quotation_dispatch_retirement)
			quotation.update(quotation_state: in_preparation)
			
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('En preparación')

			fill_in 'dispatch_group[dispatch_order]', with: 'guia123'
			attach_file('dispatch_guide_documents', Rails.root + "spec/aux/pdf_prueba.pdf", make_visible: true)
			fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'observaciones'

			expect(page).to have_css(".save-dispatch:enabled")
			first('.save-dispatch').click
			expect(page).to have_current_path(quotation_path(quotation))
			expect(quotation.dispatch_groups.size).to be 1
			
			expect(page).to have_content('pdf_prueba.pdf')
			
			dispatch_group = quotation.dispatch_groups.first
			expect(dispatch_group.dispatch_guides.count).to be 1
			expect(dispatch_group.dispatch_guides.first.document_file_name).to eq 'pdf_prueba.pdf'

			expect(page).to have_link('Despachar', href: change_dispatch_group_state_path(dispatch_group, 'Despachado'))
			execute_script("$('.collapse-dispatch-group-link').last().click()");
			expect(page).to have_selector('.send-dispatch')
			first('.send-dispatch').click
			expect(page).to have_content('Despachado')
		end

		it 'mark delivered only dispatch, with observations', js: true do 
			create(:entregado)
			create(:entrega_pendiente)
			dispatched = create(:despachado)
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: dispatched, dispatch_type: 'dispatch')
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Despachado')

			fill_in 'dispatch_group[dispatch_order]', with: 'guia123'
			attach_file('dispatch_guide_documents', Rails.root + "spec/aux/pdf_prueba.pdf", make_visible: true)
			fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'observaciones'
			# attach_file('backup_images', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			first('.save-dispatch').click
			# queda en loop esperando entrega
			expect(page).to have_current_path(quotation_path(quotation))
			
			pending "Implementar mejora MPP-922"
			
			expect(page).to have_content('Entrega Pendiente')
			expect(page).to have_content('Observación de '+manager_dispatch_user.fullname+' el día '+Date.today.strftime("%d/%m/%Y"))
			expect(page).to have_content('Falta ñeke')
			expect(page).to have_selector("input[value='abc123']")
			expect(quotation.quotation_notes.last.image_notes.size).to eq 1
			fill_in 'observations-dispatch', with: 'Ya no falta ñeke'
			first('#confirm').click
			first('#send-dispatch').click

			#lo hago avanzar a entregado

			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Entregado')
			expect(page).to have_content('Observación de '+manager_dispatch_user.fullname+' el día '+Date.today.strftime("%d/%m/%Y"))
			expect(page).to have_content('Falta ñeke')
			expect(page).to have_content('Observación de '+manager_dispatch_user.fullname+' el día '+Date.today.strftime("%d/%m/%Y"))
			expect(page).to have_content('Ya no falta ñeke')
			expect(page).to have_content('abc123')
			expect(quotation.quotation_notes.first.image_notes.size).to eq 0
		end

		it 'mark full service, no loop', js: true do 
			create(:entregado)
			create(:por_instalar)
			dispatched = create(:despachado)
			quotation = create(:quotation_dispatch_retirement)
			Quotation.last.update(quotation_state: dispatched, dispatch_type: 'dispatch+instalation')
			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Despachado')

			fill_in 'dispatch_group[dispatch_order]', with: 'guia123'
			attach_file('dispatch_guide_documents', Rails.root + "spec/aux/pdf_prueba.pdf", make_visible: true)
			fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'observaciones'

			first('.save-dispatch').click
			# pasa sin loop
			expect(page).to have_current_path(quotation_path(quotation))
			
			pending "Implementar mejora MPP-922"
			
			expect(page).to have_content('Por Instalar')
			expect(page).to have_content('Observación de '+manager_dispatch_user.fullname+' el día '+Date.today.strftime("%d/%m/%Y"))
			expect(page).to have_content('Puro newen')
			expect(page).to have_content('abc123')
		end
	end

	context 'Instalation approval' do
		before do 
			login_as(manager_instalation_user, scope: :user)
			create(:enviada)
			create(:instalado)
			create(:instalacion_pendiente)
			create(:por_activar)
			ActionMailer::Base.deliveries = []
		end

		it 'approve instalation with observations', js: true do
			for_install = create(:por_instalar)
			quotation = create(:quotation_dispatch_retirement)
			quotation.update(quotation_state: for_install, activation_confirm: true)
			quotation.quotation_products.last.update(instalation: true, available: true)

			expect(quotation.can_watch_instalation?).to be true
			expect(quotation.quotation_products.to_install.any?).to be true

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Por Instalar')

			pending 'TODO: HU de marcar un envío como pendiente de instalación'

			fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'Faltan tuercas'
			first('#pending').click
			sleep(1)
			attach_file('backup_images', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			first('#send-instalation').click
			
			#hago un loop
			wait_for_ajax
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Instalación Pendiente')
			expect(page).to have_content('Observación de '+manager_instalation_user.fullname+' el día '+Date.today.strftime("%d/%m/%Y"))
			expect(page).to have_content('Faltan tuercas')
			quotation_notes = quotation.quotation_notes.last
			expect(quotation_notes.image_notes.size).to be 1

			fill_in 'instalation_observation', with: 'Ya no faltan tuercas'
			first('#confirm').click
			first('#send-instalation').click

			expect(page).to have_current_path(quotation_path(quotation))
			click_link('Instalación')
			expect(page).to have_content('Por activar')
			expect(page).to have_content('Observación de '+manager_instalation_user.fullname+' el día '+Date.today.strftime("%d/%m/%Y"))
			expect(page).to have_content('Faltan tuercas')
			expect(page).to have_content('Observación de '+manager_instalation_user.fullname+' el día '+Date.today.strftime("%d/%m/%Y"))
			expect(page).to have_content('Ya no faltan tuercas')
			expect(quotation_notes.image_notes.size).to be 1
		end

		it 'approve instalation without observations neither activation', js: true do
			for_install = create(:por_instalar)
			quotation = create(:quotation_dispatch_retirement)
			quotation.update(quotation_state: for_install, activation_confirm: false)
			quotation.quotation_products.last.update(instalation: true, available: true)

			expect(quotation.can_watch_instalation?).to be true
			expect(quotation.quotation_products.to_install.any?).to be true

			visit quotation_path(quotation)
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Por Instalar')

			pending 'TODO: HU de marcar un envío como instalada'

			fill_in 'dispatch_group[notes_attributes][0][observation]', with: 'Todo ok master'
			first('#confirm').click
			sleep(1)
			first('#send-instalation').click
			#hago un loop
			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Instalado')
			click_link('Instalación')
			expect(page).to have_content('Observación de '+manager_instalation_user.fullname+' el día '+Date.today.strftime("%d/%m/%Y"))
			expect(page).to have_content('Todo ok master')
		end
	end

	context 'User Retail' do
		before do 
			login_as(retail_user, scope: :user)
			create(:ingresada)
			create(:en_curso)
			create(:en_preparacion)
			ActionMailer::Base.deliveries = []
		end

		it 'activate quotation', js: true do 
			Timecop.freeze(Date.new(2020, 05, 19))
			quotation = create(:retail_quotation)
			quotation.update(quotation_state: create(:ingresada))
			Product.first.retail_products << create(:retail_product, retail: Retail.first, tnr: 'ABC123')
			visit quotations_path
			expect(page).to have_current_path(quotations_path)
			expect(page).to have_content('Retail Falabella Fecha de emisión 19/05/2020 Número OC 123456789 Fecha despacho pactada 01/12/2020 Total Neto $ 719.990')
			expect(quotation.get_state).to eq 'Ingresada'
			expect(page).to have_content('Ingresada')
			Product.last.update(stock_break: false)
			expect(Product.last.stock).to eq 30
			first('.show-eye').click
			expect(page).to have_current_path(quotation_path(quotation))

			expect(page).to have_content('Retail Falabella Número F12 987654321 Fecha Emisión OC 19/05/2020 Fecha Pactada Despacho 01/12/2020')
			expect(page).to have_content('Máquina de Café CM5300 ABC123 105RR590 1 PARQUE ARAUCO - $ 699.990')

			attach_file('billing_documents', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			page.execute_script("$('#agreed_dispatch_date').val('25/12/2020')")
			first('#send-retail-activation').click

			expect(page).to have_current_path(quotation_path(quotation))
			expect(page).to have_content('Activación realizada con éxito.')
			expect(page).to have_content('En curso')
			expect(page).to have_content('25/12/2020')
			expect(Product.last.stock).to eq 29
			Timecop.return
		end

		it 'filter quotations by date', js: true do
			Timecop.freeze(Date.new(2020, 05, 02))
			quotation_2 = create(:retail_quotation, id: 2, created_at: Date.parse('01/05/2020', '%d/%m/%Y'), agreed_dispatch_date: Date.parse('04/06/2020', '%d/%m/%Y'), oc_number: 'PRUEBAZA')
			Timecop.return

			Timecop.freeze(Date.new(2020, 05, 19))
			quotation = create(:retail_quotation)
			Product.first.retail_products << create(:retail_product, retail: Retail.first, tnr: 'ABC123')
			
			visit quotations_path
			expect(page).to have_current_path(quotations_path)
			expect(all('.panel').length).to be 2

			#filtro por fecha de emisión

			fill_in 'date_range', with: '01/05/2020 - 03/05/2020'
			click_button('Guardar')
			wait_for_ajax
			expect(all('.panel').length).to be 1
			within '.panel' do
				expect(page).to have_content('Número OC PRUEBAZA')
			end
			fill_in 'date_range', with: '13/05/2020 - 21/05/2020'
			click_button('Guardar')
			wait_for_ajax
			expect(all('.panel').length).to be 1
			within '.panel' do
				expect(page).to have_content('Número OC 123456789')
			end

			#filtro por fecha pactada de despacho
			execute_script("$('#filter').select2().val('agreed_dispatch_date');")
			execute_script("$('#filter').trigger('change')")
			wait_for_ajax
			expect(all('.panel').length).to be 1

			fill_in 'date_range', with: '01/06/2020 - 30/06/2020'
			click_button('Guardar')
			wait_for_ajax
			expect(all('.panel').length).to be 0

			fill_in 'date_range', with: '20/11/2020 - 21/12/2020'
			click_button('Guardar')
			wait_for_ajax
			expect(all('.panel').length).to be 0


			fill_in 'date_range', with: '01/01/2020 - 31/12/2020'
			click_button('Guardar')
			wait_for_ajax
			expect(all('.panel').length).to be 2
			Timecop.return
		end
	end
end