require 'open-uri'
module ApplicationHelper
	
	def embed_remote_image(url, content_type)
		asset = open(url, "r:UTF-8") { |f| f.read }
		base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
		"data:#{content_type};base64,#{Rack::Utils.escape(base64)}"
	end

	def image_pdf(product)
		if product.images.size > 0
			embed_remote_image(product.images.first.image.url(:original), product.images.first.image_content_type)
		elsif product.is_service
			embed_remote_image('https:'+ActionController::Base.helpers.asset_url("shopping-cart.svg"), 'image/svg+xml')
		else
			embed_remote_image('https:'+ActionController::Base.helpers.asset_url("product.png"), 'image/png')
		end 
	end

	def step_class(step, current_step)
		if step == current_step
			return "active"
		elsif step < current_step
			return "passed"
		else
			return "pendding"
		end
	end

	def current_step(quotation)
		state = quotation.get_state
		if ['Enviada'].include?(state)
			return 1
		elsif ['En curso', 'Pendiente', 'Cerrado'].include?(state)
			return 2
		elsif ['En preparación'].include?(state)
			return 3
		elsif ['Despachado'].include?(state)
			return 4
		elsif ['Entregado','Por instalar','Instalación Pendiente'].include?(state)
			return 5
		elsif ['Instalado', 'Por activar'].include?(state)
			return 6
		elsif ['Productos activados'].include?(state)
			return 7
		end
	end

	def stock_logs(logs)
		tooltip = "<ul>"
		logs.map{ |log| tooltip += "<li><span class='log-list'>#{log.file_name} <br> (Subido el día #{log.created_at.strftime("%d/%m/%Y %H:%M")} por #{log.user.fullname})</span></li>"}
		tooltip += "</ul>"
		tooltip.html_safe
	end
end
