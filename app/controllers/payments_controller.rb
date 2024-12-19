class PaymentsController < ApplicationController
	before_action :authenticate_user!
	before_action :set_payment, only: [:destroy, :validate_payment]
	authorize_resource

	def destroy
		@quotation = @payment.quotation
		respond_to do |format|
			if @payment.destroy
				@quotation.to_state('Pendiente')
				format.html{redirect_to @quotation, notice: 'Pago eliminado con éxito.'}
			else
				format.html{redirect_to @quotation, alert: 'Hubo un problema eliminando el pago.'}
			end
		end
	end

	def validate_payment
		@quotation = @payment.quotation
		respond_to do |format|
			if @payment.update(finance_validation: true)
				QuotationMailer.payment_validated(@quotation, @payment, current_user).deliver_later if @quotation.for_project?
				format.html{ redirect_to @quotation, notice: 'Pago validado por Finanzas con éxito.'}
			else
				format.html{ redirect_to @quotation, alert: 'Hubo un problema validando el pago.'}
			end
		end
	end

	private

	def set_payment
		@payment = Payment.find_by(id: params[:id])
	end
end