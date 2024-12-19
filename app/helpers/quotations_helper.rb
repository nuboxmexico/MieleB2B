module QuotationsHelper
	def get_state_label(state, size)
		return nil unless state
		if size == "full"
			size_label = ""
		else
			size_label = "mini-label"
		end
		case state.name
		when "Enviada"
			return "<span class='state-label #{size_label} sent-state' data-toggle='tooltip' title='La cotización ha sido enviada al cliente.'>Enviada</span>".html_safe
		when "En curso"
			return "<span class='state-label #{size_label} progress-state' data-toggle='tooltip' title='La cotización ha sido enviada a finanzas para su revisión.'>En curso</span>".html_safe
		when "Pendiente"
			return "<span class='state-label #{size_label} pending-state' data-toggle='tooltip' title='El área de finanzas ha confirmado el pago parcial de esta cotización.'>Pendiente</span>".html_safe
		when "En preparación", "Despachos e Instalaciones"
			return "<span class='state-label #{size_label} preparation-state' data-toggle='tooltip' title='La cotización está siendo procesada para su despacho e instalación.'>#{state.name}</span>".html_safe
		when "Cerrado"
			return "<span class='state-label #{size_label} closed-state' data-toggle='tooltip' title='Cotización finalizada.'>Cerrado</span>".html_safe
		when "Vencida"
			return "<span class='state-label #{size_label} expired-state' data-toggle='tooltip' title='Han transcurrido los 30 días de validez para esta cotización.'>Vencida</span>".html_safe
		when "Despachado"
			return "<span class='state-label #{size_label} dispatched-state' data-toggle='tooltip' title='Se ha generado la guía de despacho para esta cotización.'>Despachado</span>".html_safe
		when "Entregado"
			return "<span class='state-label #{size_label} delivered-state' data-toggle='tooltip' title='Los productos han sido entregados al cliente.'>Entregado</span>".html_safe
		when "Por instalar"
			return "<span class='state-label #{size_label} instalation-pending-state' data-toggle='tooltip' title='Los productos han sido entregados y están pendientes de instalación.'>Por Instalar</span>".html_safe
		when "Entrega Pendiente"
			return "<span class='state-label #{size_label} pending-delivery-state' data-toggle='tooltip' title='Los productos están en camino al cliente.'>Entrega Pendiente</span>".html_safe
		when "Instalado"
			return "<span class='state-label #{size_label} instaled-state' data-toggle='tooltip' title='Los productos ya han sido instalados.'>Instalado</span>".html_safe
		when "Instalación Pendiente"
			return "<span class='state-label #{size_label} pending-instalation-state' data-toggle='tooltip' title='Los productos están pendientes de instalación.'>Instalación Pendiente</span>".html_safe
		when "Por activar"
			return "<span class='state-label #{size_label} pending-activation-state' data-toggle='tooltip' title='Los productos están pendientes de activación.'>Por activar</span>".html_safe
		when "Productos activados"
			return "<span class='state-label #{size_label} actived-products-state' data-toggle='tooltip' title='Los productos han sido activados.'>Productos activados</span>".html_safe
		when "Ingresada"
			return "<span class='state-label #{size_label} oc-first-state' data-toggle='tooltip' title='La orden de compra (OC) ha sido ingresada.'>Ingresada</span>".html_safe
		when "Cancelada"
			return "<span class='state-label #{size_label} cancel-state' data-toggle='tooltip' title='La cotización ha sida cancelada.'>Cancelada</span>".html_safe
		when "En Negociación"
			return "<span class='state-label #{size_label} negotiation-state' data-toggle='tooltip' title='La cotización está en proceso de negociación.'>En Negociación</span>".html_safe
		when "Lead"
			return "<span class='state-label #{size_label} lead-state' data-toggle='tooltip' title='Lead con datos de posible cliente.'>Lead</span>".html_safe
		when "Finalizado"
			return "<span class='state-label #{size_label} dispatched-state' data-toggle='tooltip' title='Finalizado con éxito'>Finalizado</span>".html_safe
		end
	end

	def get_title(current_user)
		if current_user.is_finance_manager? or current_user.is_finance?
			return 'Mis ventas'.html_safe
		elsif current_user.is_dispatch? or current_user.is_manager_dispatch?
			return 'Mis despachos'.html_safe
		elsif current_user.is_instalation? or current_user.is_manager_instalation?
			return 'Mis instalaciones'.html_safe
		elsif current_user.is_retail?
			return 'Mis OC'.html_safe
		else
			return 'Mis cotizaciones'.html_safe
		end
	end

	def get_name_quotation(current_user)
		if current_user.is_finance_manager? or current_user.is_finance?
			return 'venta'.html_safe
		elsif current_user.is_dispatch? or current_user.is_manager_dispatch?
			return 'despacho'.html_safe
		elsif current_user.is_instalation? or current_user.is_manager_instalation?
			return 'instalación'.html_safe
		elsif current_user.is_retail?
			return 'OC'.html_safe
		else
			return 'cotización'.html_safe
		end
	end

	def can_delete_docs(quotation)
		["Enviada", "Ingresada", "En curso", "Pendiente","En Negociación", "Lead"].include?(quotation.get_state)
	end

	def dispatch_partial_by_state(state_name)
		case state_name
			when 'En preparación'
				return 'quotations/dispatch/in_preparation'
			when 'Despachado'
				return 'quotations/dispatch/dispatched'
			else
				return 'quotations/dispatch/show'
		end
	end

	def quotation_currency_from_params
		if params[:currency].present?
			return params[:currency]
		else
			return @quotation.currency
		end
	end

	def quotation_exchange_rate_from_params
		if params[:exchange_rate].present?
			return params[:exchange_rate]
		else
			return @quotation.exchange_rate
		end
	end

	def quotation_exchange_rate_date_from_params
		if params[:exchange_rate_date].present?
			return params[:exchange_rate_date]
		else
			return @quotation.exchange_rate_date
		end
	end

	def display_quotation_currency(currency)
		case currency
			when 'clp'
				return '$'
			when 'usd', 'uf'
				return currency
			else
				return '$'
		end
	end

	def quotation_form_by_role
		if current_user.can_manage_project_quotations?
			return 'quotations/form/project_quotation'
		else
			return 'quotations/form/normal_quotation'
		end
	end

	def customer_tab_by_channel(channel)
		case channel
			when 'Retail'
				return 'quotations/customer_tab/retail'
			when 'Proyectos'
				return 'quotations/customer_tab/project'
			else
				return 'quotations/customer_tab/normal'
		end
	end

	def customer_tab_label_by_channel(channel)
		case channel
			when 'Proyectos'
				return 'Datos Proyecto'
			else
				return 'Datos Cliente'
		end
	end
end
