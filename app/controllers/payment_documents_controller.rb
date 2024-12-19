class PaymentDocumentsController < ApplicationController
	before_action :authenticate_user!
	before_action :set_document, only: [:destroy]
	authorize_resource

	def destroy
		@quotation = @document.quotation
		respond_to do |format|
			if @document.destroy
				format.html{redirect_to @quotation, notice: 'Documento eliminado con éxito.'}
			else
				format.html{redirect_to @quotation, alert: 'Hubo un problema eliminando el documento de venta.'}
			end
		end
	end

	private

	def set_document
		@document = PaymentDocument.find_by(id: params[:id])
	end
end