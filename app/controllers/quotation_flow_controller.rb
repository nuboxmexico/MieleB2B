class QuotationFlowController < ApplicationController
	before_action :authenticate_user!
	before_action :set_quotation
	authorize_resource :class => 'Quotation'

	def cancel_quotation
		Product.reverse_stock(@quotation.quotation_products) if ["Pendiente", "En curso", "En preparación","Despachado"].include?(@quotation.get_state)
		response_from_core = MieleCoreApi.restore_stock_products_on_miele_core(@quotation.quotation_products)
		@quotation.to_state('Cancelada')
		@quotation.update(progress_date: nil)
		respond_to do |format|
			if @quotation.get_state == 'Cancelada'
				#QuotationMailer.reject_quotation(@quotation).deliver_later if current_user.dispatch
				if response_from_core
					format.html{ redirect_to @quotation, notice: 'Cotización cancelada con éxito.'}
				else
					format.html{ redirect_to @quotation, alert: 'Cotización cancelada con éxito. Pero NO se logró restaurar el stock de los productos de la cotizacion en MIELE CORE'}
				end
			else
				if response_from_core # En caso que no se logro cancelar la cotizacion, se vuelve al estado anterior del stock.
					MieleCoreApi.discount_stock_products_on_miele_core(@quotation.quotation_products)
				end
				format.html{ redirect_to @quotation, alert: 'No se ha podido cancelar la cotización. Vuelva a intentarlo.'}
			end
		end
	end

	def activate
		@quotation.quotation_products
							.where(id: (params[:activation_ready_dispatch].to_a + params[:activation_ready_retirement].to_a ))
							.update(activation_ready: true)
		if params[:quotation]
			@quotation.update(v1: quotation_params[:v1])
		end

		payments_before = @quotation.payments.completed.size

		message = @quotation.load_activation_files(nil, 
																							 params[:payment_documents], 
																							 params[:sell_note_documents], 
																							 nil, 
																							 current_user)

		if (params[:payment].present? and params[:payment][:ammount].present?)
			@payment = Payment.create(payment_type: params[:payment][:payment_type], 
																ammount: params[:payment][:ammount], 
																quotation: @quotation, 
																state: 'complete',
																backup_document: params[:backup_document]) 
			QuotationMailer.new_payment_method(@quotation, @payment).deliver_later if (@payment.payment_type != 'webpay' and !@quotation.for_project?)
			QuotationMailer.new_payment_added(@quotation, @payment).deliver_later if @quotation.for_project?
			if payments_before == 0
				Product.discount_stock(@quotation.quotation_products)
				MieleCoreApi.discount_stock_products_on_miele_core(@quotation.quotation_products)
				@quotation.update(expiration_date: Date.today + 3.days)
			end			
		end

		if !params[:save_changes]
			if params[:delivery_type] == 'retiro'
				@quotation.to_state('Cerrado')
			else
				@quotation.to_state('En curso')
			end
			@quotation.update(progress_date: Date.today)
		end

		respond_to do |format|
			if message
				message = "#{message}. #{params[:save_changes] ? 'Cambios guardados con éxito.' : 'Activación realizada con éxito'}"
				format.html{ redirect_to @quotation, alert: message}
			else
				format.html{ redirect_to @quotation, notice: (params[:save_changes] ? 'Cambios guardados con éxito.' : 'Activación realizada con éxito')}
			end
		end
	end

	def dispatch_activation
		@quotation.to_state('Despachado') if params[:not_save].blank?
		respond_to do |format|
			format.html{ redirect_to @quotation, notice: 'Información de despacho registrada con éxito.'}
		end
	end

	def dispatch_confirm
		if params[:dispatch_observation] and !params[:dispatch_observation].empty?
			note = QuotationNote.create(user: current_user, observation: params[:dispatch_observation], note_type: 'dispatch', quotation: @quotation)
		end
		if params[:reception] == 'confirm' and @quotation.dispatch_type == 'dispatch+instalation'
			@quotation.to_state('Por instalar')
		elsif params[:reception] == 'confirm'
			@quotation.to_state('Entregado')
		else
			if params[:backup_images]
				params[:backup_images].each do |file|
					note.image_notes << ImageNote.create(image: file)
				end
			end
			@quotation.to_state('Entrega Pendiente')
		end
		respond_to do |format|
			format.html{ redirect_to @quotation, notice: 'Información de despacho actualizada con éxito.'}
		end
	end

	def instalation
		if params[:instalation_observation] and !params[:instalation_observation].empty?
			note = QuotationNote.create(user: current_user, observation: params[:instalation_observation], note_type: 'instalation', quotation: @quotation)
		end
		if params[:instalation_confirm] == 'confirm' and @quotation.activation_confirm
			@quotation.to_state('Por activar')
		elsif params[:instalation_confirm] == 'confirm' and !@quotation.activation_confirm
			@quotation.to_state('Instalado')
		else
			if params[:backup_images]
				params[:backup_images].each do |file|
					note.image_notes << ImageNote.create(image: file)
				end
			end
			@quotation.to_state('Instalación Pendiente')
		end
		respond_to do |format|
			format.html{ redirect_to @quotation, notice: 'Información de instalación actualizada con éxito.'}
		end
	end

	def activate_home_program
		if params[:home_program_observation] and !params[:home_program_observation].empty?
			@quotation.quotation_notes << QuotationNote.create(user: current_user, observation: params[:home_program_observation], note_type: 'home program')
		end
		@quotation.to_state('Productos activados')
		respond_to do |format|
			format.html{ redirect_to @quotation, notice: 'Información de home program actualizada con éxito.'}
		end
	end

	def load_billing_documents
		message = @quotation.load_activation_files(params[:billing_documents], 
																							 params[:payment_documents], 
																							 nil, 
																							 params[:backup_documents], 
																							 current_user)
		respond_to do |format|
			if message
				format.html{ redirect_to @quotation, alert: message}
			else
				format.html{ redirect_to @quotation, notice: 'Documentos subidos con éxito.'}
			end
		end
	end

	def negotiation_quotation
		if @quotation.get_state == 'Ingresada'
			@quotation.to_state('En Negociación')
		else
			@quotation.to_state('Ingresada')
		end
		respond_to do |format|
			format.html{ redirect_to @quotation, notice: 'Cotización actualizada con éxito.'}
		end
	end

	def close_quotation
		if @quotation.activation_confirm
			@quotation.to_state('Por activar')
		else
			@quotation.to_state('Cerrado')
		end
		@quotation.update(progress_date: Date.today)
		QuotationMailer.project_closed(@quotation).deliver_later
		respond_to do |format|
			format.html{ redirect_to @quotation, notice: 'Cotización actualizada con éxito.'}
		end
	end

	def lead_quotation
		if @quotation.get_state == 'Ingresada'
			@quotation.to_state('Lead')
		else
			@quotation.to_state('Ingresada')
		end
		respond_to do |format|
			format.html{ redirect_to @quotation, notice: 'Cotización actualizada con éxito.'}
		end
	end

	private

	def set_quotation
		@quotation = Quotation.find(params[:id])
	end

	def quotation_params
		params.require(:quotation).permit(
			:user_id,
			:project_name,
			:estimated_dispatch_date, 
			:observations,
			:document_type,
			:installation_date,
			:promotional_code_id,
			:dispatch_value,
			:sale_channel_id,
			:cost_center_id,
			:so_code,
			:paid_ammount,
			:v1,
			:retirement_date,
			:dispatch_guide,
			:dispatch_type,
			:dispatch_order,
			:activation_confirm,
			:name, 
			:lastname,
			:second_lastname,
			:rut, 
			:email, 
			:phone, 
			:dispatch_address, 
			:dispatch_commune_id, 
			:dispatch_address_number, 
			:personal_address, 
			:personal_commune_id, 
			:personal_address_number,
			:dispath_dpto_number, 
			:personal_dpto_number, 
			:business_name, 
			:business_rut,
			:business_sector,
			:instalation_address,
			:instalation_commune_id,
			:instalation_address_number,
			:instalation_address_number,
			:instalation_dpto_number,
			:billing_address, 
			:billing_commune_id,  
			:billing_address_number, 
			:billing_address_number, 
			:billing_dpto_number,
			:bstock,
			:partner_referred_id,
			:preferential_customer,
			payments_attributes: [:payment_type, :ammount, :quotation_id]
			)
	end
end