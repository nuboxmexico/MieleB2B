class DataUploadController < ApplicationController
	load_and_authorize_resource

	def upload_info
		@stock_logs = UploadLog.limit(4)
	end

	def load_photos
		count, @success = ProductImage.upload_images(params[:file])
		respond_to do |format|
			format.html{redirect_to request.env["HTTP_REFERER"], notice: "Imágenes cargadas con éxito. #{count > 0 ? count.to_s+' imágenes actualizadas.' : ''}"}
		end
	end

	def load_technical_images
		TechnicalImage.upload_technical_images(params[:file])
		respond_to do |format|
			format.html{redirect_to request.env["HTTP_REFERER"], notice: 'Imágenes técnicas cargadas con éxito.'}
		end
	end

	def load_mandatory
		@success, session[:errors] = DataUpload.load_mandatory(params[:file])
		@message = (@success and session[:errors].empty? ? 'Productos mandatorios cargados con éxito.' : 'Ha ocurrido un problema al cargar los productos mandatorios.')
		respond_html
	end

	def load_products
		@success, session[:errors] = DataUpload.load_products(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'Productos cargados con éxito.' : 'Ha ocurrido un problema al cargar los productos.' )
		respond_html
	end

	def load_discounts
		@success, session[:errors] = ProductDiscount.load_discounts(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'Descuentos cargados con éxito.' : 'Ha ocurrido un problema al cargar los descuentos.')
		respond_html
	end

	def load_addressees
		@success, session[:errors] = EmailAddressee.load_addressees(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'Destinatarios cargados con éxito.' : 'Ha ocurrido un problema al cargar los destinatarios.')
		respond_html
	end

	def load_stock
		@success, session[:errors] = DataUpload.load_stock(params[:file])
		UploadLog.create(file_name: params[:file].original_filename, user: current_user) if (@success and session[:errors].empty?)
		@message = ((@success and session[:errors].empty?) ? 'Información de stock cargada con éxito.' : 'Ha ocurrido un problema al cargar la información de stock.')
		respond_html
	end

	def load_comparator_info
		@success, session[:errors] = ComparableAttribute.load_comparator_info(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'Información del comparador cargada con éxito.' : 'Ha ocurrido un problema al cargar la información del comparador.')
		respond_html
	end

	def load_homologate_tnr
		@success, session[:errors] = Retail.load_tnr_retail(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'TNRs retail cargados con éxito.' : 'Ha ocurrido un problema al cargar los TNRs de retail.')
		respond_html
	end

	def load_oc_retail
		quotations, @success, session[:errors] = DataUpload.load_oc_retail(params[:file], current_user)
		quotations.each do |quotation|
			quotation.quotation_document.destroy if quotation.quotation_document
			pdf = render_to_string new_quotation_pdf(quotation)
			quotation.save_document(pdf)
		end
		@message = ((@success and session[:errors].empty?) ? 'Ocs de retail cargados con éxito.' : 'Ha ocurrido un problema al cargar las OCs de retail.')
		respond_html
	end

	def load_save_margen
		@success, session[:errors] = DataUpload.save_margen(params["margen"])
		@message = ((@success) ? 'Margen de cotizaciones Proyectos cargado con éxito.' : 'Ha ocurrido un problema al cargar el Margen de cotizaciones Proyectos')
		respond_html
	end

	def load_quotation_project
		quotations, @success, session[:errors] = DataUpload.load_quotation_project(params[:file], current_user)
		quotations.each do |quotation|
			quotation.quotation_document.destroy if quotation.quotation_document
			pdf = render_to_string new_quotation_pdf(quotation)
			quotation.save_document(pdf)
		end
		@message = ((@success and session[:errors].empty?) ? 'Cotizaciones de Project cargados con éxito.' : 'Ha ocurrido un problema al cargar las cotizaciones de Project.')
		respond_html
	end

	def load_cost_center
		@success, session[:errors] = CostCenter.upload_cost_centers(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'Centros de costo cargados con éxito.' : 'Ha ocurrido un problema al cargar los centros de costo.')
		respond_html
	end

	def load_miele_roles
		@success, session[:errors] = MieleRole.upload_roles(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'ID de usuarios cargados con éxito.' : 'Ha ocurrido un problema al cargar los ID de usuarios.')
		respond_html
	end

	def load_project_installation_value
		@success, session[:errors] = ProjectInstallationValue.upload_project_installation_value(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'Valores de instalación cargados con exito' : 'Ha ocurrido un problema al cargar los valores de instalación')
		respond_html
	end

	def load_project_installation_discount
		@success, session[:errors] = ProjectInstallationDiscount.upload_project_installation_discount(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'Valores de instalación cargados con exito' : 'Ha ocurrido un problema al cargar los valores de instalación')
		respond_html
	end

	def load_dispatch_rule
		@success, session[:errors] = DispatchRule.upload_dispatch_rule(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'Valores de instalación cargados con exito' : 'Ha ocurrido un problema al cargar los valores de instalación')
		respond_html
	end

	def load_commission_levels
		@success, session[:errors] = CommissionParameter.upload_commissions_parameters(params[:file])
		@message = ((@success and session[:errors].empty?) ? 'Tramos de comisiones cargados con éxito.' : 'Ha ocurrido un problema al cargar los tramos de comisiones.') 
		respond_html	
	end

	def download_stock
		@products = Product.where(ean: nil).order('sku ASC')
		respond_to do |format|
			format.xlsx{render xlsx: 'download_stock', filename: "plantilla_stock_#{Date.today.strftime("%d/%m/%Y")}.xlsx"}
		end
	end

	def download_products
		@products = Product.all.order('sku ASC')
		respond_to do |format|
			format.xlsx{render xlsx: 'download_products', filename: "plantilla_productos_#{Date.today.strftime("%d/%m/%Y")}.xlsx"}
		end
	end

	def download_discounts
		@discounts = ProductDiscount.all.order('discount ASC')
		respond_to do |format|
			format.xlsx{render xlsx: 'download_discounts', filename: "plantilla_descuentos_#{Date.today.strftime("%d/%m/%Y")}.xlsx"}
		end
	end

	def download_addressees
		@addressees = EmailAddressee.all.order(:process,:user_id)
		respond_to do |format|
			format.xlsx{render xlsx: 'download_addressees', filename: "plantilla_destinatarios_#{Date.today.strftime("%d/%m/%Y")}.xlsx"}
		end
	end

	def download_commissions_table
		@table = CommissionParameter.all.order('lower_bound ASC')
		respond_to do |format|
			format.xlsx{render xlsx: 'download_commissions_table', filename: "plantilla_comisiones_#{Date.today.strftime("%d/%m/%Y")}.xlsx"}
		end
	end

	def download_cost_center
		@cost_centers = CostCenter.all.order('code ASC')
		respond_to do |format|
			format.xlsx{render xlsx: 'download_cost_center', filename: "plantilla_cost_center_#{Date.today.strftime("%d/%m/%Y")}.xlsx"}
		end
	end

	def download_miele_roles
		@miele_roles = MieleRole.all.order('code ASC')
		respond_to do |format|
			format.xlsx{render xlsx: 'download_miele_roles', filename: "plantilla_id_usuarios_#{Date.today.strftime("%d/%m/%Y")}.xlsx"}
		end
	end

	def download_tnr_homologated
		@products = Product.all.joins(:retail_products).uniq
		respond_to do |format|
			format.xlsx{render xlsx: 'download_tnr_homologated', filename: "plantilla_tnr_retail_#{Date.today.strftime("%d/%m/%Y")}.xlsx"}
		end
	end

	def template_project
		@filename = "plantilla_project"
		send_template
	end

	def template_project_installation_values
		@filename = "plantilla_proyectos_valores_instalaciones"
		send_template
	end

	def template_project_installation_discounts
		@filename = "plantilla_valores_descuentos_instalaciones"
		send_template
	end

	def template_dispatch_rules
		@filename = "plantilla_reglas_despacho"
		send_template
	end

	def template_commissions
		@filename = "plantilla_comisiones"
		send_template
	end

	def template_miele_roles
		@filename = "plantilla_id_usuarios"
		send_template
	end

	def template_cost_center
		@filename = "plantilla_cost_center"
		send_template
	end

	def template_oc_retail
		@filename = "plantilla_oc_retail"
		send_template
	end

	def template_tnr_retail
		@filename = "plantilla_tnr_retail"
		send_template
	end

	def template_addressees
		@filename = "plantilla_destinatarios"
		send_template
	end

	def update_customer_core_ids
		session[:errors] = []
		@success = true
		non_registered_emails = Customer.where(core_id:nil).map { |customer| customer.replicate_in_core("From B2B") ? nil : customer.email }.compact
		unless non_registered_emails.empty?
			session[:errors] = [-3,non_registered_emails]
			@success = false
		end
		@message = ((@success and session[:errors].empty?) ? 'Se ha actualizado el Miele Core ID de todos los clientes.' : "Ha ocurrido un problema al actualizar el Miele Core ID de los clientes.")
		respond_html
	end

	def update_product_core_ids
		session[:errors] = []
		@success = true
		non_registered_sku = Product.bulk_update_core_id
		unless non_registered_sku
			session[:errors] = [-4,non_registered_sku]
			@success = false
		end
		@message = ((@success and session[:errors].empty?) ? 'Se ha actualizado el Miele Core ID de todos los productos.' : "Ha ocurrido un problema al actualizar el Miele Core ID de los productos.")
		respond_html
	end

	# Metodo que sincroniza los productos del b2b con miele core y genera un reporte en formato .json
	def synchronizeProductsWithMieleCore
		session[:errors] = []
		@success = false
		@message = "Ha ocurrido un problema al sincronizar los productos con Miele Core"

		obj_response = RequestDataMieleCore.synchronizeProductsWithMieleCore
		
		if obj_response[:status] == 400
			session[:errors] = obj_response[:errors].first(4)
			session[:errors].push(' ... Vea el reporte de sincronizacion en su correo para mas detalles')
			@message = "#{obj_response[:message]}. Vea el reporte de sincronizacion en su correo para mas detalles "
		elsif obj_response[:status] == 200
			@succes = true
			@message = obj_response[:message]
		end
		UserMailer.report_notification_sync_with_core('Proceso de sincronizacion Miele Customers con Miele Core', current_user.email, obj_response).deliver_later
		respond_html
	end
	
	private 

	def respond_html
		respond_to do |format|
			if @success and session[:errors].empty?
				format.html{redirect_to upload_info_path, notice: @message}
			else
				format.html{redirect_to upload_info_path, alert: @message}
			end
		end 
	end
end