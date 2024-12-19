class QuotationRetailController < ApplicationController
	before_action :authenticate_user!
	before_action :set_quotation
	authorize_resource :class => 'Quotation'

	def update_quantities
		QuotationProduct.update(params[:quotation_product].keys, params[:quotation_product].values)
		@quotation.quotation_document.destroy if @quotation.quotation_document
		pdf = render_to_string new_quotation_pdf(@quotation)
		@quotation.save_document(pdf)
		respond_to do |format|
			format.html{ redirect_to @quotation, notice: 'Cantidades actualizadas con éxito.'}
		end
	end

	def activate_retail
		message = @quotation.load_activation_files(params[:billing_documents], nil, nil, nil, current_user)
		@quotation.update(agreed_dispatch_date: params[:agreed_dispatch_date])
		@quotation.to_state('En curso')
		@quotation.update(progress_date: Date.today)
		Product.discount_stock(@quotation.quotation_products)
		response_from_core = MieleCoreApi.discount_stock_products_on_miele_core(@quotation.quotation_products)

		respond_to do |format|
			if message 
				if response_from_core
					format.html{ redirect_to @quotation, alert: "#{message}. Activación realizada con éxito."}
				else
					format.html{ redirect_to @quotation, alert: "#{message}. Activación realizada con éxito, pero no se logro Descontar Stock de products en Miele Core"}
				end
			else
				if response_from_core
					format.html{ redirect_to @quotation, notice: 'Activación realizada con éxito.'}
				else 
					format.html{ redirect_to @quotation, alert: "Activación realizada con éxito, pero no se logro Descontar Stock de products en Miele Core"}
				end
			end
		end
	end

	def activate_finance_retail
		@quotation.update(so_code: params[:so_code], oc_validation: params[:oc_validation], credit_note: params[:credit_note])
		if params[:finance_observations] and !params[:finance_observations].empty?
			@quotation.quotation_notes << QuotationNote.create(user: current_user, observation: params[:finance_observations], note_type: 'finance')
		end
		save_credit_notes if params[:credit_note_documents].present?
		@quotation.to_state("En preparación")
		respond_to do |format|
			format.html{ redirect_to @quotation, notice: 'Activación realizada con éxito.'}
		end
	end

	private

	def set_quotation
		@quotation = Quotation.find(params[:id])
	end

	def save_credit_notes
		params[:credit_note_documents].each do |file|
			@quotation.credit_notes.create!(:document => file)
			@quotation.save!
		end
	end
end