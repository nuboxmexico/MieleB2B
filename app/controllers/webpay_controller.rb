class WebpayController < ApplicationController
	skip_before_action :verify_authenticity_token
	skip_authorization_check :only => [:webpay_return_url, :webpay_final_url, :webpay_success, :webpay_error, :webpay_nullify, :already_paid, :terms_and_conditions, :download_terms]
	before_action :set_quotation, only: [:webpay_error, :webpay_nullify, :already_paid, :terms_and_conditions]
	layout 'webpay'

	def return_url
    webpay_response = WebpayPlus.transaction_confirmation(params[:token_ws])
		if webpay_response and 
			 (payment = Payment.find_by(miele_tx_code: webpay_response['buy_order'])) and 
			 webpay_response['response_code'] == 0

			payment.transaction do 
				payment.update(tbk_token: params[:token_ws],
										 webpay_data: webpay_response['legacy_format'],
										 state: 'complete',
										 pay_date: Time.now,
										 verified: true)
			end

			redirect_to webpay_success_path(token_ws: params[:token_ws])
		elsif payment
			quotation = payment.quotation
			payment.destroy
			redirect_to webpay_error_path(quotation)
		else
			payment = Payment.find_by(miele_tx_code: params['TBK_ORDEN_COMPRA'])
			quotation = payment.quotation
			payment.destroy
			redirect_to webpay_nullify_path(quotation)
		end
	end		

	def webpay_final_url
		@payment = Payment.find_by(tbk_token: params[:token_ws])
		if(params[:TBK_ID_SESION] == nil)
			QuotationMailer.payment_notification(@payment.quotation, @payment).deliver_later
			redirect_to webpay_success_path(token_ws: params[:token_ws])
		else
			@quotation = @payment.quotation
			@payment.destroy
			redirect_to webpay_nullify_path(@quotation)
		end
	end

	def webpay_success
		@payment = Payment.where(tbk_token: params[:token_ws]).lock(true).take
	end

	def webpay_error
	end

	def webpay_nullify
	end

	def already_paid
	end

	def terms_and_conditions
		can_pay, @payment = @quotation.prepare_payment
		if !can_pay
			redirect_to already_paid_path(@quotation) 
			return
		end
	end

	def download_terms
		send_file(
			"#{Rails.root}/public/resources/terminos_y_condiciones_miele_2023.pdf",
			filename: "terminos_y_condiciones_miele_2023.pdf",
			type: "application/pdf",
			disposition: 'inline'
			)
	end

	private 

	def set_quotation
		@quotation = Quotation.find_by(id: params[:id])
	end
end