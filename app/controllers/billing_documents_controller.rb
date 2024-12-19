class BillingDocumentsController < ApplicationController
	before_action :authenticate_user!
	before_action :set_document, only: [:destroy]
	authorize_resource

	def destroy
		@quotation = @document.quotation
		respond_to do |format|
			if @document.destroy
				format.html{redirect_to @quotation, notice: 'Comprobante de pago eliminado con éxito.'}
			else
				format.html{redirect_to @quotation, alert: 'Hubo un problema eliminando el comprobante de pago.'}
			end
		end
	end

	private

	def set_document
		@document = BillingDocument.find_by(id: params[:id])
	end
end