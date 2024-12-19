class BannersController < ApplicationController
	before_action :authenticate_user!
	before_action :set_banner, only: [:destroy]
	load_and_authorize_resource

	def index
		@banners = Banner.all.order('created_at desc').paginate(page: params[:page], per_page: 12)
		@items = Banner.all.size
	end

	def create
		respond_to do |format|
			if Banner.create!(banner_params)
				format.html{redirect_to banners_path, notice: 'Banner promocional creado con éxito.'}
			else
				format.html{redirect_to new_banner_path, alert: 'No se pudo crear el banner promocional. Vuelva a intentarlo.'}
			end
		end
	end

	def new
		@banner = Banner.new
	end

	def destroy
		@success = (@banner.destroy ? true : false)
		respond_to do |format|
			format.js
		end
	end

	def reference_banner
		send_file(
			"#{Rails.root}/public/resources/referencia.jpg",
			filename: "referencia.jpg",
			type: "image/jpg"
			)
	end

	private

	def set_banner
		@banner = Banner.find_by(id: params[:id])
	end

	def banner_params
		params.require(:banner).permit(:banner_image, :url, :start_date, :end_date, :banner_mobile)
	end
end