class CreditNotesController < ApplicationController
	before_action :authenticate_user!
	before_action :set_document, only: [:destroy]
	authorize_resource

	def destroy
		@quotation = @document.quotation
		respond_to do |format|
			if @document.destroy
				format.html{redirect_to @quotation, notice: 'Nota de crédito eliminada con éxito.'}
			else
				format.html{redirect_to @quotation, alert: 'Hubo un problema eliminando la nota de crédito.'}
			end
		end
	end

	private

	def set_document
		@document = CreditNote.find_by(id: params[:id])
	end
end