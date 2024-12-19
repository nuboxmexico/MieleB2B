class Dashboard
	STARTED = ["Enviada", "En curso", "Pendiente", "Vencida", "Ingresada", "Cancelada","En Negociación"]
	PROGRESS = ["En preparación", "Cerrado", "Despachado", "Entregado", "Por instalar", "Entrega Pendiente", "Instalado", "Instalación Pendiente", "Por activar", "Productos activados"]
	
	def self.quotations_by_state(user, start_date = (DateTime.now - 3.months), end_date = DateTime.now)
		channels = ((user.administrator? or user.is_manager_inventory?) ? SaleChannel.all : [] << user.sale_channel)
		progress_counter = []
		started_counter = []
		channels.each do |channel|
			started_counter << channel.quotations.where(next_version: nil, created_at: start_date..end_date, progress_date: nil).joins(:quotation_state).where(quotation_states: {name: STARTED}).uniq.size
			in_progress = channel.quotations.where(next_version: nil, progress_date: start_date..end_date).joins(:quotation_state).where(quotation_states: {name: PROGRESS}).uniq.size
			if channel.name == 'E-commerce'
				in_progress += EcommerceSale.where(selled_at: start_date..end_date).size
			end
			progress_counter << in_progress
		end
		return {
			categories: channels.pluck(:name),
			data: [
				{
					name: 'En Progreso',
					data: progress_counter,
					color: '#D5243D'
				},
				{
					name: 'Creadas',
					data: started_counter,
					color: '#FD9184'
				}				
			]
		}
	end

	def self.quotation_products_per_channel_and_product_type(user, start_date = (DateTime.now - 3.months), end_date = DateTime.now)
		channels = ((user.administrator? or user.is_manager_inventory?) ? SaleChannel.all : [] << user.sale_channel)
		product_type_per_channel = {}
		channels.each do |channel|
			sum_price_by_product_type = channel.quotations.joins(:quotation_state, quotation_products: [:product]).where(quotations: {next_version: nil, progress_date: start_date..end_date}, quotation_states: {name: PROGRESS}).group('products.product_type').sum('(quotation_products.price * quotation_products.quantity) - quotation_products.discount')
			sum_price_by_product_type['Despacho'] = channel.quotations.joins(:quotation_state).where(quotations: {next_version: nil, progress_date: start_date..end_date}, quotation_states: {name: PROGRESS}).sum(:dispatch_value)
			if channel.name == 'E-commerce'
				ecommerce_sum_price = EcommerceSale.joins(quotation_products: [:product]).where(ecommerce_sales: {selled_at: start_date..end_date}).group('products.product_type').sum('quotation_products.total')
				sum_price_by_product_type.merge!(ecommerce_sum_price){|key, oldval, newval| newval + oldval}
			end
			product_type_per_channel[channel.name] = sum_price_by_product_type 
		end

		product_type_name = Product.distinct.pluck(:product_type).push("Despacho")
		product_type_color = product_type_name.zip(["#F59B00", "#8C0314", "#FD9184", "#D5423D", "#FDC568"]).to_h
		
		product_type_data = product_type_name.map do |type_name|
			{
				name: type_name == "" ? "Serv" : type_name,
				data: channels.pluck(:name).map {|channel_name| product_type_per_channel[channel_name].fetch(type_name,0)},
				color: product_type_color.fetch(type_name, '#000000')
			}
		end

		return {
			categories: channels.pluck(:name),
			data: product_type_data
		}
	end

	def self.products_most_selled(user, start_date = (DateTime.now - 3.months).beginning_of_day, end_date = DateTime.now.end_of_day)
		products_base = ((user.administrator? or user.is_manager_inventory?) ? Product.all : user.sale_channel.products)
		quotations_base = ((user.administrator? or user.is_manager_inventory?) ? Quotation.all : user.sale_channel.quotations)
		top_10 = products_base.joins(:quotation_products).where('quotation_products.created_at BETWEEN ? AND ?', start_date, end_date).group('products.id').order(Arel.sql('SUM(quotation_products.quantity) DESC')).limit(10)
		progress_counter = []
		started_counter = []
		top_10.each do |prod|
			started = 0
			in_progress = 0
			quotations_base.where(next_version: nil, created_at: start_date..end_date, progress_date: nil).joins(:quotation_state, :quotation_products).where(quotation_states: {name: STARTED}, quotation_products: {product: prod}).uniq.map{|quo| started += quo.quotation_products.find_by(product: prod).quantity}
			quotations_base.where(next_version: nil, progress_date: start_date..end_date).joins(:quotation_state, :quotation_products).where(quotation_states: {name: PROGRESS}, quotation_products: {product: prod}).uniq.map{|quo| in_progress += quo.quotation_products.find_by(product: prod).quantity}
			if user.administrator? or user.is_manager_inventory? or user.try(:sale_channel).try(:name) == 'E-commerce'
				EcommerceSale.where(selled_at: start_date..end_date).joins(:quotation_products).where(quotation_products: {product: prod}).uniq.map{|sale| in_progress += sale.quotation_products.find_by(product: prod).quantity}
			end
			progress_counter << in_progress 
			started_counter << started
		end
		return {
			categories: top_10.pluck(:name),
			data: [
				{
					name: 'Cotizaciones En Progreso',
					data: progress_counter,
					color: '#D5243D'
				},
				{
					name: 'Cotizaciones Creadas',
					data: started_counter,
					color: '#FD9184'
				}				
			]
		}
	end

	def self.quotations_per_channel(user, start_date = (DateTime.now - 3.months), end_date = DateTime.now)
		channels = ((user.administrator? or user.is_manager_inventory?) ? SaleChannel.all : [] << user.sale_channel)
		channel_data = []
		drilldown_data = []
		channels.each do |channel|
			total_channel = 0
			channel.quotations.joins(:quotation_state).where(quotations: {next_version: nil, progress_date: start_date..end_date}, quotation_states: {name: PROGRESS}).uniq.map{|quo| total_channel += quo.total}
			channel_data << {name: channel.name, y: (channel.name == 'E-commerce' ? (EcommerceSale.where(selled_at: start_date..end_date).sum(:total) + total_channel) : total_channel), color: channel.color, drilldown: channel.name}
			cc_quotations_t = []
			CostCenter.all.each do |cc|
				total = 0
				cc.quotations.where(next_version: nil, progress_date: start_date..end_date, sale_channel: channel).joins(:quotation_state).where(quotation_states: {name: PROGRESS}).uniq.map{|quo| total += quo.total}
				if total > 0
					cc_quotations_t << [cc.name, ((channel.name == 'E-commerce' and cc.code = 36) ? (EcommerceSale.where(selled_at: start_date..end_date).sum(:total) + total) : total)]
				end
			end
			drilldown_data << {name: channel.name, id: channel.name, data: cc_quotations_t}
		end

		return {
			data: {
				name: 'Canales de Venta',
				colorByPoint: true,
				data: channel_data
			}, 
			drilldown: {
				series: drilldown_data
			}
		}
	end
end