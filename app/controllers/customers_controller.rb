class CustomersController < ApplicationController
	before_action :set_quotation, only: [:find_by_rut_and_code]
	before_action :authenticate_user!, except: [:search_tracking, :find_by_rut_and_code]
	skip_authorization_check :only => [:search_tracking, :find_by_rut_and_code]
	layout 'customer', only: [:find_by_rut_and_code]

	def search
		rut_t = params[:rut].gsub('-','')
		@customers = Customer.where('rut ilike ? ', '%'+rut_t+'%')
		respond_to do |format|
			format.json
		end
	end

	def search_tracking
	end

	def find_by_rut_and_code
		unless @quotation
			redirect_to search_tracking_path, alert: 'La cotización que estás buscando no existe.'
		end
	end

	private

	def set_quotation
		@quotation = Quotation.find_by(rut: params[:rut].downcase, code: params[:code])
	end
end