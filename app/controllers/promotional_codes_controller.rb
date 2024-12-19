class PromotionalCodesController < ApplicationController
	before_action :authenticate_user!
	authorize_resource

	def index
		@codes = PromotionalCode.all.order('id DESC').paginate(page: params[:page], per_page: 10)
		@items = PromotionalCode.all.size
	end

	def new
		@code = PromotionalCode.new
	end

	def create
		respond_to do |format|
			if PromotionalCode.create_with_sale_channel(promotional_code_params)
				format.html{redirect_to promotional_codes_path, notice: 'Código de descuento creado con éxito.'}
			else
				format.html{redirect_to new_promotional_code_path, alert: 'No se pudo crear el código de descuento. Vuelva a intentarlo.'}
			end
		end
	end

	private

	def promotional_code_params
		params.require(:promotional_code).permit(:name, :code, :percent, :description, :start_date, :end_date, :use_limit, :is_for_product, sale_channels: [])
	end
end