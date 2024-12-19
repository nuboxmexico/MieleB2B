class QuotationsController < ApplicationController
	before_action :authenticate_user!, except: [:pay_debt]
	before_action :set_cart     , only: [:new, :create, :check_dispatch, :edit, :update, :checkout, :new_unit_real_state]
	before_action :set_quotation, only: [:resumen, :show, :update, :destroy,
											:pay_debt, :update_quotation, :reactivate, :reactivate_for_project, :edit,
											:pdf, :new_version, :send_dispatch_configuration_alert, :set_instalation_check, :create_associations, :get_unit_real_states]
	#before_action :reset_dispatch, only: [:new]
	before_action :set_customer, only: [:create, :update]
	before_action :check_inventory_user, except: :pay_debt
	before_action :set_base_quotations, only: :search
	before_action :set_communes_for_select, only: [:new, :edit, :show]
	before_action :set_all_real_state_companies, only: [:new, :show, :edit]
	skip_authorization_check only: :pay_debt
	require 'will_paginate/array'

	@@unit_real_states = 0
	@@project_installation_values = []
	@@project_installation_discounts = []
	@@dispatch_rules = []

	include ActionView::Helpers::NumberHelper

	def index
		if params[:retail]
			@quotations = Retail.find_by(name: params[:retail])
													.quotations
													.where(next_version: nil)
													.includes(:quotation_state)
													.order('quotation_states.stage asc, quotations.updated_at desc')
		elsif current_user.seller?
			@quotations = current_user.quotations
																.where(next_version: nil)
																.includes(:quotation_state)
																.order('quotation_states.stage asc, quotations.updated_at desc')
		elsif current_user.manager?
			@quotations = current_user.sale_channel
																.quotations
																.where(next_version: nil)
																.includes(:quotation_state)
																.order('quotations.updated_at desc')
		elsif current_user.administrator?
			@quotations = Quotation.where(next_version: nil)
														 .includes(:quotation_state)
														 .order('quotations.updated_at desc')
		elsif current_user.is_dispatch? or current_user.is_manager_dispatch?
			@quotations = Quotation.where(next_version: nil)
														 .joins(:quotation_state)
														 .merge(QuotationState.dispatcher)
														 .order('quotation_states.stage asc, quotations.updated_at desc')
		elsif current_user.is_finance? or current_user.is_finance_manager?
			@quotations = Quotation.where(next_version: nil)
														 .joins(:quotation_state)
														 .merge(QuotationState.finance)
														 .order('quotation_states.stage asc, quotations.updated_at desc')
		elsif current_user.is_instalation? or current_user.is_manager_instalation?
			@quotations = Quotation.joins(:quotation_state, :quotation_products)
														 .merge(QuotationState.instalator)
														 .where(quotation_products: {instalation: true},
														 				quotations: {next_version: nil})
														 .order('quotation_states.stage asc, quotations.updated_at desc')
		end

		if params[:date_range].present?
			start_date, end_date = params[:date_range].split(' - ').map{|date| DateTime.parse(date)}
			if start_date != end_date
				@quotations = @quotations.where(updated_at: start_date.beginning_of_day..end_date.end_of_day)
			end
		end

		if params[:states].present?
			@quotations = @quotations.joins(:quotation_state).where(quotation_states: {id: params[:states]})
		end

		if params[:sale_channels].present?
			@quotations = @quotations.where(sale_channel_id: params[:sale_channels])
		end

		if params[:cost_centers].present?
			@quotations = @quotations.joins(:cost_center).where(cost_centers: {id: params[:cost_centers]})
		end

		unless current_user.administrator? or current_user.is_project?
			if current_user.sale_channel.try(:name) == 'Retail'
				@total_per_period = @quotations.inject(0){ |sum, quotation|  sum + quotation.total_retail }
			elsif params[:filter].present?
				@total_per_period = @quotations.inject(0){ |sum, quotation|  sum + quotation.send(params[:filter]).to_i }
			end
		end

		@quotations = @quotations.uniq
		@items = @quotations.count

		respond_to do |format|
			format.html{ @quotations = @quotations.paginate(page: params[:page], per_page: 10) }
			format.xlsx{ render xlsx: (current_user.is_project? ?  'download_for_project' : 'download_commissions') , filename: "#{current_user.is_project? ? "cotizaciones_proyectos" : "cotizaciones"}_#{Date.today.strftime("%d/%m/%Y")}.xlsx"}
		end
	end

	def search
		if current_user.is_retail?
			@quotations = @quotations.joins(:quotation_products, :retail, :user).where("quotations.sale_channel_id = ? and (translate(LOWER(oc_number),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(f12_number),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(quotation_products.sku),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(quotation_products.name),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(retails.name),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(so_code),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(users.name),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(users.lastname),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(users.second_lastname),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(quotation_products.tnr_retail),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? )",
				SaleChannel.find_by(name: 'Retail').id, '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%',  '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%',
				'%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%',  '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%',
				'%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%').uniq
		else
			@quotations = @quotations.joins(:user).joins('LEFT OUTER JOIN communes ON communes.id = quotations.dispatch_commune_id').where("translate(LOWER(code),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(quotations.name),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(quotations.oc_number),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(dispatch_address),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(quotations.email),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(so_code),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(code),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(users.name),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(users.lastname),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				translate(LOWER(users.second_lastname),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
				rut ilike ? or business_rut ilike ? or translate(LOWER(communes.name),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? ", '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%',
				'%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%',
				'%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%','%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_quotation]).downcase+'%').uniq
		end
		@items = @quotations.size
		respond_to do |format|
			format.html {@quotations = @quotations.paginate(page: params[:page], per_page: 10)}
			format.json
		end
	end

	def new
		if @cart.cart_items.present?
			@dispatch_products = @cart.get_dispatch_products
			@products_instalation_number = 0
			@products_dispatch_number = 0
			@cart.cart_items.each do |item|
				@products_instalation_number = @products_instalation_number + item["quantity"].to_i if item["instalation"]
				@products_dispatch_number = @products_dispatch_number + item["quantity"].to_i if item["dispatch"]
			end
			@project_installation_values = ProjectInstallationValue.all
			project_installation_values_aux = []
			@project_installation_discounts = ProjectInstallationDiscount.all
			project_installation_discounts_aux = []
			if current_user.is_project?
				@project_installation_values.each do |valor|
					project_installation_values_aux.push({
						min_amount: valor["min_amount"],
						max_amount: valor["max_amount"],
						cost_RM: CartHelper.clp_to_UF(valor["cost_RM"]),
						cost_additional_region:  CartHelper.clp_to_UF(valor["cost_additional_region"])
					})
					
				end
				@project_installation_discounts.each do |valor|
					project_installation_discounts_aux.push({
						min_amount: CartHelper.clp_to_UF(valor["min_amount"]),
						max_amount: CartHelper.clp_to_UF(valor["max_amount"]),
						discount_percentage: valor["discount_percentage"]
					})
				end
			end
			@project_installation_values = project_installation_values_aux
			@project_installation_discounts = project_installation_discounts_aux
			@@dispatch_rules = DispatchRule.all
			@dispatch_rules = @@dispatch_rules
			@total_cost = @cart.total_cost
			if current_user.is_project?
				@quotation = check_quotation_token
				discount_percentage = @quotation.calculate_discount_percentage(@cart)
				@quotation.update(percentage_discount_dispatch: discount_percentage)
			else
				redirect_to edit_quotation_path(@cart.quotation) if @cart.quotation
				@quotation = Quotation.new(user: current_user)
			end
		else
			redirect_to cart_path, alert: "No hay productos para cotizar"
		end
	end

	def checkout
		if @cart.cart_items.present?
			if current_user.is_project?
				@@unit_real_states = 0
				@unit_real_states = @@unit_real_states
				@products_instalation_number = 0
				
				@cart.cart_items.each do |item|
					@products_instalation_number = @products_instalation_number + 1 if item["instalation"]
					
				end

			else
				redirect_to root_path, alert: 'Acceso no autorizado.'
			end
		else
			redirect_to cart_path, alert: "No hay productos para cotizar"
		end
	end

	def set_instalation_check
		@quotation.update(instalation_check: params["instalation_check"])
	end

	def new_unit_real_state 
		@quotation = check_quotation_token
		@@unit_real_states = @@unit_real_states + 1
		@project_installation_values = @@project_installation_values
		@project_installation_discounts = @@project_installation_discounts
		@unit_real_states = @@unit_real_states
		@helper ||= Class.new do
			include ActionView::Helpers::NumberHelper
		  end.new
		respond_to do |format|
			format.js
		end
	end

	def get_dispatch_cost
		@quotation = check_quotation_token
		render json: @quotation.get_dispatch_cost(params["commune"]).to_json
	end

	def get_dispatch_cost_show
		@quotation = Quotation.find(params["quotation_id"]);
		render json: @quotation.get_dispatch_cost(params["commune"]).to_json
	end

	def set_dispatch_value
		quotation = Quotation.find(params["quotation_id"]);
		quotation.update(dispatch_value: params["dispatch_value"])
		render json: { status: "OK" }
	end

	def set_installation_value
		quotation = Quotation.find(params["quotation_id"]);
		quotation.update(installation_value: params["installation_value"])
		render json: { status: "OK" }
	end


	def checkout_instalation 
	end

	def create
		create_quotation
		create_associations if @quotation.for_project?
		if @success
			QuotationMailer.new_quotation(@quotation).deliver_later unless @quotation.for_project?
			if @quotation.for_project?
				render :new
			else
				redirect_to quotation_resumen_path(@quotation)
			end
		else
			render :new
		end
	end

	def show
		@technicians_show = DispatchGroup.get_technicians(Rails.application.secrets.country_CL, "Entregas/Despachos")
		@payment_type_options =[["Pago en efectivo","efectivo"],["Pago con Transferencia", "transferencia"],["Pago Mixto", "mixto"],["Pago Trasbank Tienda", "transbank tienda"],["Pago Webpay (Link)", "webpay link"], ['Saldo a favor', 'saldo a favor']]
		@payment_type_options.push(*[["Cheque","cheque"],["Depósito directo","deposito directo"]]) if current_user.is_project?
		@versions = @quotation.all_versions

		@dispatch_products = @quotation.quotation_products.where(dispatch: true)
		
		@products_instalation_number = @quotation.products_instalation_number
		@products_per_assign_number = @quotation.products_per_assign_number
		
		@products_dispatch_number = @quotation.products_dispatch_number
		@products_dispatch_per_assign_number = @quotation.products_dispatch_per_assign_number

		@not_found_skus_in_core = @quotation.quotation_products.map do |qp|
			qp.product.sku unless qp.product.core_id || qp.product.sku == 'PEM'
		end.compact

		@not_found_skus_in_quotation_in_core = @quotation.quotation_products.map do |qp|
			qp.product.sku unless  qp.core_id
		end.compact

		#TODO: Se requiere un método en el modelo para enmendar productos en cotizaciones.
		@can_approve = (
											current_user.is_finance_manager? or
											(@quotation.all_completed_payments_are_of_same_type?('webpay') and
										 	current_user.is_finance?)
									 )
		@pending_products_in_dispatch = @quotation.pending_products_in_dispatch
		fetch_quotations_products
		@detail_quotation_products = @quotation.pending_detail_products_in_dispatch
		@to_install_detail_quotation_products = @quotation.pending_to_install_detail_products
		
		@installation_sheets = @quotation.installation_sheets

		@project_installation_values = @quotation.project_installation_values
		@project_installation_discounts = @quotation.project_installation_discounts

		respond_to do |format|
			format.html
			format.pdf do
				@batched_items = @quotation.quotation_products.find_in_batches(batch_size: 4)
				render @quotation.to_pdf(params.has_key?(:debug))
			end
		end
	end

	def edit
	end

	def update
		#TODO: Este método hace muchas cosas debe ser separado por funcionalidad.
		if params[:duplicate_quotation] == 'on'
			#creo una nueva
			begin
				create_quotation
				create_associations if @quotation.for_project?
				@success = true
				@duplicated = true
				QuotationMailer.new_quotation(@quotation).deliver_later unless @quotation.for_project?
			rescue => e 
				puts "ERROR: #{e}"
				@success = false
			end
		elsif params[:edit].present?
			begin

				@quotation = params[:creation].present? ? check_quotation_token : @cart.quotation
				# elimino el token
				@quotation.update(guest_token: nil)
				# actualizo los campos de la cotización
				@quotation.update!(quotation_params)
				# borro los productos q ya estaban
				@quotation.quotation_products.destroy_all
				# vuelvo a cargar los productos
				@quotation.save_products(@cart, current_user)
				# seteo algunos campos
				@quotation.update(pay_percent: @cart.pay_percent, dispatch_code: @cart.dispatch_code, referred_user: @customer.try(:user))
				# actualizo todos los calculos asociados
				set_adjusts
				# genero denuevo el pdf
				@quotation.quotation_document.destroy if @quotation.quotation_document
				generate_pdf

				create_associations if @quotation.for_project?
				@quotation.set_code
				@quotation.update_total

				if @quotation.for_project?
					observations = params["quotation"]["observations"].nil? ? "": params["quotation"]["observations"]
					check_customer(observations)
					@quotation.update(customer_id: @customer.try(:id))
				end

				QuotationMailer.new_quotation(@quotation).deliver_later unless @quotation.for_project?
				@success = true
			rescue Exception => e
				puts "ERROR: #{e}"
				@success = false
			end
		else
			#TODO: Tanto el proceso de venta como el proceso de confirmación de venta pasan por acá.
			# Deben ser aislados en sus propios métodos.
			review_version if params.dig(:quotation, :valid_quotation) == "1"
			@quotation.update!(quotation_params)
			save_credit_notes if params[:credit_note_documents].present?
			if (dispatch_instruction_files = params[:quotation][:dispatch_instruction_files])
				@quotation.save_dispatch_instructions_files(dispatch_instruction_files)
			end
			if @quotation.for_project?
				if quotation_params[:paid_ammount]
					if quotation_params[:paid_ammount] == @quotation.pay_percent
						@quotation.to_state("Pendiente")
					elsif params[:change_state] == "true" && (current_user.is_finance_manager? || current_user.is_finance?)
						check_workflow
						@quotation.replicate_in_core(@quotation)
						@quotation.update(expiration_date: Date.today+180.days)
						make_dispatch_groups(@quotation)
					end
				end
				create_associations
			else
				if quotation_params[:paid_ammount]
					if quotation_params[:paid_ammount] != "100"
						@quotation.to_state("Pendiente")
					elsif params[:change_state] == "true" && (current_user.is_finance_manager? || current_user.is_finance?)
						check_workflow
						@quotation.replicate_in_core(@quotation)
						@quotation.update(expiration_date: Date.today+180.days)
						if_is_ecommerce_quotation_make_only_one_dispatch_group(@quotation)
					end
				end
			end

			@quotation.set_code
			@quotation.update_total

			if @quotation.for_project?
				observations = params["quotation"]["observations"].nil? ? "": params["quotation"]["observations"]
				check_customer(observations) unless quotation_params[:paid_ammount]
				@quotation.update(customer_id: @customer.try(:id)) unless quotation_params[:paid_ammount]
			end

			@success = true
		end

		@quotation.update(uf_day: Indicator.find_by(name: "uf").value) if @quotation.for_project? && @quotation.uf_day.nil?
		@quotation.update(expiration_date: (Date.today + 30.days)) if @quotation.for_project?

		respond_to do |format|
			if @success
				if @duplicated
					format.html{ redirect_to @quotation, notice: 'Se ha creado una nueva cotización exitosamente'}
				else
					format.html{ redirect_to @quotation, notice: 'Cotización actualizada con éxito'}
				end
			else
				format.html{ redirect_to @quotation, alert: 'No se ha podido actualizar la cotización'}
			end
		end
	end

	def check_dispatch
		respond_to do |format|
			format.js{ (@success = @cart.update(dispatch_value: Quotation.check_dispatch(params[:commune], @cart.cart_items), installation_value: Quotation.check_installation(params[:commune], @cart.cart_items), dispatch_code: nil)).to_json }
		end
	end

	def destroy
		next_quotation = @quotation.next_version
		previous_quotation = Quotation.find_by(next_version: @quotation)
		previous_quotation.try(:update,{ next_version: next_quotation })
		@quotation.update(next_version_id: nil)
		@quotation.destroy

		respond_to do |format|
			format.html{ redirect_to quotation_path, notice: 'Cotización eliminada' }
			format.json{ render json: {url: quotation_path(next_quotation)}.to_json }
		end

	end

	def resumen
	end

	def pay_debt
		can_pay, payment = @quotation.prepare_payment
		if can_pay
			if (webpay_response = WebpayPlus.init_transaction(@quotation))
        render html: webpay_response.body.html_safe
			else
				redirect_to webpay_error_path
				return
      end
		else
			redirect_to already_paid_path(@quotation)
			return
		end
	end

	def update_quotation
		@quotation.attributes = quotation_params
		@updated = @quotation.changed.first
		respond_to do |format|
			if @quotation.save
				format.js{@success = true}
			else
				format.js{@success = false}
			end
		end
	end

	def reactivate
		respond_to do |format|
			if @quotation.quotation_products.joins(:product).where('products.stock > 0 AND quotation_products.available = TRUE').size > 0
				@quotation.quotation_products.map { |prod| prod.update(available: (prod.product.stock > 0 ? true : false), price: prod.product.display_price(current_user)[1], quantity: ((prod.product.stock >= prod.quantity) ? prod.quantity : prod.product.stock), created_at: DateTime.now)}
				@quotation.update(total: @quotation.total_calc)
				@quotation.update(expiration_date: Product.offer_deadline(@quotation.quotation_products.pluck(:product_id), (current_user.manager? or current_user.seller?) ? [current_user.sale_channel.id] : SaleChannel.all.pluck(:id))[0])

				@quotation.quotation_document.destroy if @quotation.quotation_document
				generate_pdf

				@quotation.check_commission
				@quotation.update(dispatch_value: Quotation.check_dispatch(@quotation.dispatch_commune_id, @quotation.quotation_products), total: @quotation.total_calc)
				@quotation.to_state('Enviada', true)
				QuotationMailer.new_quotation(@quotation, true).deliver_later
				format.html { redirect_to @quotation, notice: 'Cotización reactivada con éxito.'}
			else
				format.html { redirect_to @quotation, alert: 'No fue posible reactivar la cotización porque ninguno de los productos cuenta con stock disponible.'}
			end
		end
	end

	def reactivate_for_project
		respond_to do |format|
			if @quotation.quotation_products.joins(:product).where('products.stock > 0 AND quotation_products.available = TRUE').size > 0
				@quotation.quotation_products.each { |prod| prod.update(available: (prod.product.stock > 0 ? true : false), quantity: ((prod.product.stock >= prod.quantity) ? prod.quantity : prod.product.stock), created_at: DateTime.now) }
				@quotation.update_total
				@quotation.update(expiration_date: (Date.today + 30.days))
				@quotation.update(uf_day: Indicator.find_by(name: "uf").value)
				@quotation.to_state('En Negociación')
				format.html { redirect_to @quotation, notice: 'Cotización reactivada con éxito.'}
			else
				format.html { redirect_to @quotation, alert: 'No fue posible reactivar la cotización porque ninguno de los productos cuenta con stock disponible.'}
			end
		end
	end

	def new_version
		with_products = true
		if params.has_key?(:quotation) and !params.has_key?(:items)
			@quotation.update(quotation_params)
			@quotation.set_code
		end
		if params.has_key?(:quotation) and params.has_key?(:items)
			new_version = @quotation.create_new_version(!with_products)
			new_version.update(quotation_params)
			new_version.set_code
			
			# Agregar productos a nueva version; tambien son los disponibles para agregar a grupos de envio y config de unidades inmobiliarias
			new_products = []
			params[:items].each do |id, item|
				new_product = @quotation.quotation_products.find(item[:id]).dup
				new_product.price = item[:price]
				new_product.quantity = item[:quantity]
				new_products << new_product
			end
			new_version.quotation_products << new_products
			
			# Agregar productos en grupos de envio a nueva version
			new_version.dispatch_groups.each_with_index do |new_disp_group, index|
				new_disp_group.quotation_products_auxes << @quotation.dispatch_groups.map { |old| old }[index].quotation_products_auxes.map { |item| item.dup }
			end
		  
			# Agregar productos a config de unidades inmobiliarias; en el modelo se agregaron las config de unidades inmobiliarias
			new_version.config_unit_real_states.each_with_index do |new_config_unit, index|
				new_config_unit.product_in_unit_real_states << @quotation.config_unit_real_states.map {|old| old}[index].product_in_unit_real_states.map { |item| item.dup }
			end
			
			new_version.save
			new_version.update_total
			# new_version.set_products_in_dispatch_group
		end

		respond_to do |format|
			format.html{ redirect_to @quotation, notice: 'Datos del proyecto actualizados' }
			format.json{ render json: {url: quotation_path(new_version)}.to_json }
		end
	end

	def send_dispatch_configuration_alert
		QuotationMailer.dispatch_configuration_alert(@quotation).deliver_later
		redirect_to @quotation, notice: 'Notificación enviada con éxito'
	end

	def get_unit_real_states
		render json: @quotation.unit_real_states.to_json
	end


	def update_total_from_view
		@quotation = Quotation.find(params[:id])
		if @quotation.update(total: params["total_value"])
			respond_to do |format|
				format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: @quotation, what_refresh: { amount: true } } }
			end
		else
			render json: { error: "No se pudo actualizar el total" }, status: :internal_server_error
		end
	end

	private

	def fetch_quotations_products
		if @quotation.customer.blank?
			create_quotation_products
			return
		end
		@customer_products = []
		set_customer_products
		return [] unless @customer_products.count.positive?

		products_ids = @quotation.quotation_products.pluck(:core_id)
		@quotation_products = []
		@customer_products.each do |cp|
			@quotation_products.push(cp) if products_ids.include? cp['id']
		end
		@quotation_products.each do |qp|
			next if qp['instalation_date'].blank?

			array = qp['instalation_date'].split("-")
			qp['instalation_date'] = "#{array[2]}/#{array[1]}/#{array[0]}"
		end
	end

	def create_quotation_products
		@all_detail_quotation_products = @quotation.all_detail_products_in_dispatch
		@quotation_products = []
		@all_detail_quotation_products.each do |qp|
			@quotation_products.push({
				"product": {
					"name": qp.name,
					"tnr": qp.tnr
				},
				"serial_id": qp.serial_id,
				"status": qp.state,
				"instalation_date": nil
			})
		end
	end

	def review_version
		next_quotation = @quotation.next_version
		previous_quotation = Quotation.find_by(next_version: @quotation)

		return if next_quotation.nil? and previous_quotation.nil?

		previous_quotation.try(:update,{ next_version: next_quotation })
		@quotation.update(next_version_id: nil)

		[previous_quotation, next_quotation].compact.last.all_versions.first.update(next_version: @quotation)

		@quotation.all_versions.select(&:valid_quotation).each{ |quotation| quotation.update(valid_quotation: false)}
	end

	def check_customer(observations)
		if !@customer
			@customer = Customer.create(quotation_params.except(:project_name, :estimated_dispatch_date, :document_type, :observations, :dispatch_value, :installation_value, :sale_channel_id, :cost_center_id, :installation_date, :retirement_date, :promotional_code_id, :bstock, :partner_referred_id, :preferential_customer, :apply_discount,:miele_role_id, :real_state_name, :currency, :exchange_rate, :exchange_rate_date, :valid_quotation, :so_code, :credit_note, :paid_ammount))
			@customer.update_in_core(
				observations, 
				quotation_params.as_json.merge({ "code" => @quotation.try(:code), "quotation_id" => @quotation.try(:id) })
			)unless @customer.replicate_in_core(
					observations, 
					quotation_params.as_json.merge({ "code" => @quotation.try(:code), "quotation_id" => @quotation.try(:id) })
				)
		else
			@customer.update(quotation_params.except(:project_name, :estimated_dispatch_date, :observations, :document_type, :dispatch_value, :installation_value, :sale_channel_id, :cost_center_id, :installation_date, :retirement_date, :promotional_code_id, :bstock, :partner_referred_id, :preferential_customer, :apply_discount,:miele_role_id, :real_state_name, :currency,  :exchange_rate, :exchange_rate_date, :valid_quotation, :so_code, :credit_note, :paid_ammount))
			@customer.update_in_core(observations, quotation_params.as_json.merge({ "code" => @quotation.try(:code), "quotation_id" => @quotation.try(:id) }))
		end
		@customer
	end

	def generate_pdf
		pdf = render_to_string new_quotation_pdf(@quotation)
		@quotation.save_document(pdf)
	end

	def create_quotation
		observations = params["quotation"]["observations"].nil? ? "": params["quotation"]["observations"]
		check_customer(observations)
		@quotation = current_user.quotations.new(quotation_params.as_json.merge({"customer_id" => @customer.id }))

		@quotation.set_code
		
		if @quotation.save && @quotation.save_products(@cart, current_user) &&
			 @quotation.update(pay_percent: @cart.pay_percent,
			 									 dispatch_code: @cart.dispatch_code,
			 									 referred_user: @customer.user)
			set_adjusts
			generate_pdf
			@success = true
		else
			@success = false
		end
	end

	def create_associations
		unless real_state_company = RealStateCompany.find_by(name: quotation_params['real_state_name'])
			real_state_company = RealStateCompany.create(name: quotation_params['real_state_name'])
		end
		if builder_company = real_state_company.builder_companies.find_by(rut: quotation_params['business_rut'])
			@quotation.update(builder_company_id: builder_company.id)
		else
			builder_company = BuilderCompany.create(
				name: quotation_params['business_name'],
				rut: quotation_params['business_rut'],
				sector: quotation_params['business_sector'],
				real_state_company_id: real_state_company.id
			)
			@quotation.update(builder_company_id: builder_company.id)
		end
	end

	def make_dispatch_groups(quotation)
		if quotation.dispatch_groups 
			quotation.dispatch_groups.each do |dg|
				dg.quotation_products_auxes.each do |qpa|
					qpa.quantity.to_i.times do |i|
						detail_quotation_products = quotation.pending_detail_products_in_dispatch
						detail_quotation_product = detail_quotation_products.select { |pd| pd.tnr == qpa.sku }.first
						detail_quotation_product.update(
							dispatch_group_id: dg.id,
							dispatched: true
						)
					end
				end

				unless dg.notes.dispatch.last
					DispatchNote.create(
						user_id: current_user.id, 
						dispatch_group_id: dg.id, 
						category: "dispatch", 
						observation: ""
					)
				end
			end
		end

	end

	def set_customer_products
		customer_from_core = MieleCoreApi.find_customer_by_id(@quotation.customer.core_id)
		return false unless customer_from_core.present?
		
		@customer_products = customer_from_core['data']['customer_products'] rescue []
	end

	def set_adjusts
		if @quotation.for_project?
			total = @quotation.total_calc(params["quotation"]["total"].to_f.round())
			@quotation.update(total:total )
		else
			@quotation.update(total: @quotation.total_calc)
		end
		@cart.clean
		@quotation.check_commission
		@quotation.check_partner_commission(@customer)
		@customer.check_partner(@quotation, current_user) if @customer
		@quotation.update(activation_confirm: true) if @quotation.quotation_products.find_by(product: Product.find_by(name: 'Home Program'))
	end

	def set_base_quotations
		if current_user.manager?
			@quotations = current_user.sale_channel.quotations
		elsif current_user.seller?
			if current_user.is_mca?
				@quotations = current_user.miele_role.quotations
			else
				@quotations = current_user.cost_center.quotations
			end
		else
			@quotations = Quotation.all
		end
	end

	def check_workflow

		home_program = Product.find_by(sku: 'PEM')
		previsit = Product.find_by(sku: 'SERV01')
		# si solo está home program
		if @quotation.quotation_products.find_by(product: home_program) and (@quotation.quotation_products.size == 1)
			@quotation.to_state('Por activar')
		# si solo está previsita
		elsif @quotation.quotation_products.find_by(product: previsit) and (@quotation.quotation_products.size == 1)
			@quotation.to_state('Por instalar')
		# si solo están los servicios
		elsif (@quotation.quotation_products.where(product: [home_program.try(:id), previsit.try(:id)]).size == 2) and (@quotation.quotation_products.size == 2)
			@quotation.to_state('Por instalar')
		# flujo normal
		else
			@quotation.to_state("En preparación")
			# Actualizar Estado de la order asociado en el ecommerce B2C
			# if	@quotation.sale_channel
			# 	if @quotation.sale_channel.name == "E-commerce"
			# 		ecommerce_sale = EcommerceSale.find_by(quotation_id:@quotation.id) rescue nil
			# 		if ecommerce_sale
			# 			#MieleEcommerceApi.update_state_of_b2c_order(ecommerce_sale.order_code,"ready")
			# 		end
			# 	end
			# end
		end
	end

	# Este metodo fuerza a que una cotizacion proveniente del B2C, se le asigne solamente un grupo de despacho
	def if_is_ecommerce_quotation_make_only_one_dispatch_group(quotation) 
		if @quotation.sale_channel
			if @quotation.sale_channel.name == "E-commerce" and 
				@quotation.cost_center.name == "WebShop" and
				@quotation.quotation_state.name == "En preparación" 
				new_dg = DispatchGroup.create(
					state: QuotationState.find_by(name: 'En preparación'),
					quotation_id: quotation.id)

				quotation.quotation_products.each do |qp|
					qp.detail_quotation_products.each do |dq|
						dq.update!(dispatch_group_id:new_dg.id,dispatched: true)
					end 
				end
			end
		end
	end 

	def check_inventory_user
		redirect_to root_path if current_user.is_manager_inventory?
	end

	def set_cart
		@cart = Cart.find_or_create_by(user: current_user)
	end

	def set_quotation
		@quotation = Quotation.find(params[:id])
		@quotation_order = EcommerceSale.find_by(quotation_id:params[:id]).order_code rescue nil
	end

	def set_customer
		@customer = Customer.find_by(rut: quotation_params[:rut]) unless quotation_params[:rut].nil? || quotation_params[:rut].empty?
	end

	def set_all_real_state_companies
		@all_real_state_companies = RealStateCompany.all
	end

	def reset_dispatch
		@cart.update(dispatch_value: 0)
		@cart.update(dispatch_code: nil)
	end

	def save_credit_notes
		params[:credit_note_documents].each do |file|
			@quotation.credit_notes.create!(:document => file)
			@quotation.save!
		end
	end

	def set_communes_for_select
		@communes_for_select = Commune.includes(:region).map do |commune|
			["#{commune.name}, #{commune.region.name}", commune.id]
		end
	end

	def quotation_params
		params.require(:quotation).permit(
			:user_id,
			:project_name,
			:real_state_name,
			:estimated_dispatch_date,
			:observations,
			:document_type,
			:installation_date,
			:promotional_code_id,
			:dispatch_value,
			:installation_value,
			:total_value,
			:sale_channel_id,
			:cost_center_id,
			:so_code,
			:paid_ammount,
			:v1,
			:retirement_date,
			:dispatch_guide,
			:dispatch_type,
			:dispatch_order,
			:activation_confirm,
			:name,
			:lastname,
			:second_lastname,
			:rut,
			:email,
			:phone,
			:mobile_phone,
			:dispatch_address,
			:dispatch_address_street_type,
			:dispatch_commune_id,
			:dispatch_address_number,
			:personal_address,
			:personal_address_street_type,
			:personal_commune_id,
			:personal_address_number,
			:dispath_dpto_number,
			:personal_dpto_number,
			:business_name,
			:business_rut,
			:business_sector,
			:instalation_address_street_type,
			:instalation_address,
			:instalation_commune_id,
			:instalation_address_number,
			:instalation_address_number,
			:instalation_dpto_number,
			:billing_address,
			:billing_address_street_type,
			:billing_commune_id,
			:billing_address_number,
			:billing_address_number,
			:billing_dpto_number,
			:bstock,
			:partner_referred_id,
			:preferential_customer,
			:apply_discount,
			:credit_note,
			:dispatch_dpto_number,
			:miele_role_id,
			:currency,
			:exchange_rate_date,
			:exchange_rate,
			:valid_quotation,
			:uf_day
			)
	end
end
