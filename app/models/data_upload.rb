class DataUpload
	def self.load_mandatory(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
		if !headers.include? 'TNR' or !headers.include? 'INS01' or !headers.include? 'TNR MAN01' or !headers.include? 'INS02' or !headers.include? 'TNR MAN02' or !headers.include? 'INS03' or !headers.include? 'TNR MAN03' 
			return false, [-1]
		else
			file_errors = []
			i = 0
			spreadsheet.each(sku: 'TNR', instalation_1: 'INS01', instalation_2: 'INS02', instalation_3: 'INS03', tnrs_1: 'TNR MAN01', tnrs_2: 'TNR MAN02', tnrs_3: 'TNR MAN03') do |row|
				if i > 0
					sku_t = (row[:sku].kind_of?(String) ? row[:sku] : row[:sku].to_i.to_s)
					if (product_t = Product.find_by(sku: sku_t, ean: nil))

						if !row[:instalation_1].nil? and !row[:instalation_1].empty? and !(ins_t = Instalation.find_by(name: row[:instalation_1], product_id: product_t.id))
							ins_t = Instalation.create!(name: row[:instalation_1], product_id: product_t.id)
						end

						mandatory_t = (row[:tnrs_1].kind_of?(Float) ? row[:tnrs_1].to_i.to_s : row[:tnrs_1].to_s)
						mandatories = mandatory_t.split('_')
						if mandatories.size > 0
							mandatories.each do |mandatory|
								if (mandatory_t = Product.find_by(sku: mandatory, ean: nil)) and !MandatoryProduct.find_by(instalation_id: ins_t.id, product_id: mandatory_t.id)
									MandatoryProduct.create!(instalation_id: ins_t.id, product_id: mandatory_t.id)
								end
							end
						end

						if !row[:instalation_2].nil? and !row[:instalation_2].empty? and !(ins_t = Instalation.find_by(name: row[:instalation_2], product_id: product_t.id))
							ins_t = Instalation.create!(name: row[:instalation_2], product_id: product_t.id)
						end

						mandatory_t = (row[:tnrs_2].kind_of?(Float) ? row[:tnrs_2].to_i.to_s : row[:tnrs_2].to_s)
						mandatories = mandatory_t.split('_')
						if mandatories.size > 0
							mandatories.each do |mandatory|
								if (mandatory_t = Product.find_by(sku: mandatory, ean: nil)) and !MandatoryProduct.find_by(instalation_id: ins_t.id, product_id: mandatory_t.id)
									MandatoryProduct.create!(instalation_id: ins_t.id, product_id: mandatory_t.id)
								end
							end
						end

						if !row[:instalation_3].nil? and !row[:instalation_3].empty? and !(ins_t = Instalation.find_by(name: row[:instalation_3], product_id: product_t.id))
							ins_t = Instalation.create!(name: row[:instalation_3], product_id: product_t.id)
						end

						mandatory_t = (row[:tnrs_3].kind_of?(Float) ? row[:tnrs_3].to_i.to_s : row[:tnrs_3].to_s)
						mandatories = mandatory_t.split('_')
						if mandatories.size > 0
							mandatories.each do |mandatory|
								if (mandatory_t = Product.find_by(sku: mandatory, ean: nil)) and !MandatoryProduct.find_by(instalation_id: ins_t.id, product_id: mandatory_t.id)
									MandatoryProduct.create!(instalation_id: ins_t.id, product_id: mandatory_t.id)
								end
							end
						end
					end
				end
				i += 1
			end
		end
		return true, file_errors
	end

	def self.save_margen(margen_value)
		file_errors = []
		margen = Indicator.where(name: "margen").take
		if margen
			margen = margen.update(value: margen_value.to_f)
		else
			margen = Indicator.create(name: "margen", value: margen_value.to_f)
		end
		if margen 
			return true, file_errors
		else
			return false,file_errors
		end
	end

	def self.load_stock(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
		if !headers.include? 'TNR' or !headers.include? 'Stock' or !headers.include? 'Quiebre Stock?'
			return false, [-1]
		else
			file_errors = []
			i = 0
			spreadsheet.each(sku: 'TNR', stock: 'Stock', stock_break: 'Quiebre Stock?') do |row|
				if i > 0
					begin
						sku_t = (row[:sku].kind_of?(String) ? row[:sku] : row[:sku].to_i.to_s)
						if product_t = Product.find_by(sku: sku_t, ean: nil)
							product_t.with_lock do 
								product_t.update(stock: row[:stock], stock_break: (row[:stock_break].try(:downcase) == 'si' ? true : false))
								product_t.check_linked_quotations
							end
						else
							file_errors.push(i+1)
						end
					rescue Exception => e 
						file_errors.push(i+1)
					end
				end
				i += 1
			end
		end
		return true, file_errors
	end

	def self.load_products(file)
		begin
			if !(spreadsheet = User.open_spreadsheet(file)) or !(product_sheet = spreadsheet.sheet('Cargador productos'))
				return false, [-2]
			end
		rescue Exception => e
			return false, [-2]
		end
		headers = []

		product_sheet.row(1).each_with_index {|header,i| headers.push(header) }
		headers_required = ["Costo", "TNR", "Business Unit", "Familia", "Subfamilia", "Nombre", "Descripción", "Precio", "Mandatorio", "Canal", "Retirable", 
			"Despachable", "Tipo", "Específico", "Built-in", "Instalación", "Outlet", "Especificaciones", "Características", "Especificaciones técnicas", "Funciones",
			"Especialidades de bebidas", "Diseño de los cestos", "Programa de lavado", "Programa de secado", "Cuidado y mantenimiento", "Seguridad", "Eficiencia y sostenibilidad",
			"Accesorios y suministros", "Centro de beneficios", "EAN", "Categoría", "Estado Equipos", "Descuento", "Centro Costo", "B-Stock", "Precio EUR"]
			if !headers_required.all? { |e| headers.include?(e) }
				return false, [-1]
			else
				file_errors = []
				i = 0
				spreadsheet.each(cost: 'Costo', price_eur: 'Precio EUR', sku: 'TNR', business_unit: 'Business Unit',family: 'Familia', subfamily: 'Subfamilia', name: 'Nombre', description: 'Descripción', price: 'Precio', mandatory: 'Mandatorio', channel: 'Canal', can_retire: 'Retirable', can_ship: 'Despachable', type: 'Tipo', specific: 'Específico', built_in: 'Built-in', instalation: 'Instalación', outlet: 'Outlet', specs: "Especificaciones", features: "Características", technical_specs: "Especificaciones técnicas", product_functions: "Funciones", drink: "Especialidades de bebidas", basket_design: "Diseño de los cestos", wash_program: "Programa de lavado", dry_program: "Programa de secado", care: "Cuidado y mantenimiento", security: "Seguridad", sustain: "Eficiencia y sostenibilidad", accessories: "Accesorios y suministros", profit_center: "Centro de beneficios", ean: "EAN", category: "Categoría", state: "Estado Equipos", discount: "Descuento", cost_center: "Centro Costo", bstock: "B-Stock") do |row|
					if i > 0
						if (unit_t = Family.find_by(name: row[:business_unit].try(:strip))) and row[:price] and row[:sku]
							sku_t = (row[:sku].kind_of?(String) ? row[:sku] : row[:sku].to_i.to_s)
							if product_t = Product.find_by(sku: sku_t, ean: row[:ean])
								product_t.update(
									name: row[:name], 
									description: row[:description], 
									price: row[:price], 
									price_eur: row[:price_eur],
									cost: row[:cost], 
									mandatory: (row[:mandatory].try(:downcase) == 'si'), 
									dispatch: (row[:can_ship].try(:downcase) == 'si'), 
									can_retire: (row[:can_retire].try(:downcase) == 'si'), 
									product_type: row[:type], 									
									instalation: (row[:instalation].try(:downcase) == 'si'), 
									built_in: (row[:built_in].try(:downcase) == 'si'), 
									outlet: (row[:outlet].try(:downcase) == 'si'),
									specs: row[:specs], 
									features: row[:features], 
									technical_specs: row[:technical_specs], 
									product_functions: row[:product_functions], 
									drink_specialty: row[:drink], 
									basket_design: row[:basket_design],
									wash_program: row[:wash_program], 
									dry_program: row[:dry_program], 
									maintenance_care: row[:care], 
									security: row[:security], 
									efficiency_sustain: row[:sustain], 
									accessories: row[:accessories], 
									profit_center: (row[:profit_center].try(:downcase) == 'si'),
									ean: row[:ean], 
									category: row[:category], 
									state: row[:state], 
									discount: row[:discount], 
									cost_center: CostCenter.find_by(code: row[:cost_center]), 
									bstock: (row[:bstock].try(:downcase) == 'si'))
							else
								product_t = Product.create(
									sku: sku_t, 
									name: row[:name], 
									description: row[:description], 
									price: row[:price], 
									price_eur: row[:price_eur],
									cost: row[:cost], 
									mandatory: (row[:mandatory].try(:downcase) == 'si'), 									
									dispatch: (row[:can_ship].try(:downcase) == 'si'), 
									can_retire: (row[:can_retire].try(:downcase) == 'si'), 
									product_type: row[:type], 
									instalation: (row[:instalation].try(:downcase) == 'si'), 
									built_in: (row[:built_in].try(:downcase) == 'si'), 
									outlet: (row[:outlet].try(:downcase) == 'si'),
									specs: row[:specs], 
									features: row[:features], 
									technical_specs: row[:technical_specs], 
									product_functions: row[:product_functions], 
									drink_specialty: row[:drink], 
									basket_design: row[:basket_design],
									wash_program: row[:wash_program], 
									dry_program: row[:dry_program], 
									maintenance_care: row[:care], 
									security: row[:security], 
									efficiency_sustain: row[:sustain], 
									accessories: row[:accessories], 
									profit_center: (row[:profit_center].try(:downcase) == 'si'),
									ean: row[:ean], 
									category: row[:category], 
									state: row[:state], 
									discount: row[:discount], 
									cost_center: CostCenter.find_by(code: row[:cost_center]), 
									bstock: (row[:bstock].try(:downcase) == 'si'))
							end
							product_t.sale_channels.destroy_all if product_t.sale_channels
							if row[:channel].present?
								product_t.sale_channels << SaleChannel.where(name: row[:channel].split(',').map{|channel|channel.strip})
							else
								product_t.sale_channels << SaleChannel.all
							end
							if !product_t.families.include?(unit_t)
								product_t.families << unit_t
								product_t.save!
							end

							if row[:family] and !row[:family].empty?
								if !family_t = unit_t.children.find_by(name: row[:family].try(:strip))
									family_t = Family.create(name: row[:family].try(:strip), family_id: unit_t.id, depth: 1)
								else
									product_t.families << family_t
									product_t.save!
								end
							end

							if row[:subfamily] and !row[:subfamily].empty? 
								if !subfamily_t = family_t.children.find_by(name: row[:subfamily].try(:strip))
									subfamily_t = Family.create(name: row[:subfamily].try(:strip), family_id: family_t.id, depth: 2)
								else
									product_t.families << subfamily_t
									product_t.save!
								end
							end

							if row[:specific] and !row[:specific].empty? 
								if !specific_t = subfamily_t.children.find_by(name: row[:specific].try(:strip))
									specific_t = Family.create(name: row[:specific].try(:strip), family_id: subfamily_t.id, depth: 3)
								else
									product_t.families << specific_t
									product_t.save!
								end
							end

						else
							file_errors.push(i+1)
						end
					end
					i += 1
				end
			end
			return true, file_errors
		end

		def self.load_quotation_project(file, current_user)
			if !(spreadsheet = User.open_spreadsheet(file))
				return [], false, [-2]
			end
			headers = []
			spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
			headers_required = ["Fecha de ingreso Proyecto (DD/MM/AAA)","Correlativo","Proyecto","Nombre Cliente","Apellido Paterno","Apellido Materno","RUT","Correo","Teléfono","Dirección Proyecto","Comuna Proyecto","Dirección de Despacho/Instalación","Comuna Despacho/Instalación","Centro de Costo","TNR","Cantidad","Valor oferta Unitario Propuesto NETO","Moneda (CLP o UF)","Home Program","Borrar","Observaciones","Lead", "Fecha de Despacho"]
			if !headers_required.all? { |e| headers.include?(e) }
				return [], false, [-1]
			else
				file_errors = []
				quotations = []
				i = 0
				spreadsheet.each(created_at: "Fecha de ingreso Proyecto (DD/MM/AAA)", correlative: "Correlativo", project_name: "Proyecto", name: "Nombre Cliente", lastname: "Apellido Paterno", second_lastname: "Apellido Materno", rut: "RUT", email: "Correo", phone: "Teléfono", personal_address: "Dirección Proyecto", personal_commune_id: "Comuna Proyecto", dispatch_address: "Dirección de Despacho/Instalación", dispatch_commune_id: "Comuna Despacho/Instalación", cost_center_id: "Centro de Costo", sku: "TNR", quantity: "Cantidad", price: "Valor oferta Unitario Propuesto NETO", currency: "Moneda (CLP o UF)", activation_confirm: "Home Program", delete: "Borrar", observations: "Observaciones", lead: "Lead", estimated_dispatch_date: "Fecha de Despacho") do |row|
					if i > 0
						begin
							if row[:currency] == 'UF'
								row[:currency] = :uf
							elsif row[:currency] == 'CLP'
								row[:currency] = :clp									
							end
							row[:personal_commune_id] = Commune.find_by(name: row[:personal_commune_id]).try(:id)
							row[:dispatch_commune_id] = Commune.find_by(name: row[:dispatch_commune_id]).try(:id)
							row[:cost_center_id] = CostCenter.find_by(code: row[:cost_center_id]).try(:id)
							row[:miele_role_id] = current_user.miele_role_id
							row[:sale_channel_id] = current_user.sale_channel_id
							row[:user_id] = current_user.id
							row[:activation_confirm] = (row[:activation_confirm].try(:downcase) == 'si' ? true : false)
							if row[:created_at].present? and row[:correlative].present? and row[:observations].present?
								if (quotation_t = Quotation.find_by(correlative: row[:correlative]))
									quotation_t.update(row.except(:sku, :price, :quantity, :delete, :lead))
								else
									quotation_t = Quotation.create(row.except(:sku, :price, :quantity, :delete, :lead))
								end
								quotations << quotation_t
								if [nil,"Ingresada","Lead", 'En Negociación'].include?(quotation_t.get_state)
									if row[:lead].try(:downcase) == 'si'
										quotation_t.to_state('Lead')
									else
										quotation_t.to_state('Ingresada')
									end
								end
								sku_t = (row[:sku].kind_of?(String) ? row[:sku] : row[:sku].to_i.to_s)
								if (product_t = Product.find_by(sku: sku_t)) and row[:price].present? and row[:quantity].present?
									if (item_t = quotation_t.quotation_products.find_by(product: product_t))
										if row[:delete].try(:downcase) == 'si'
											item_t.destroy
										else
											item_t.update(price: row[:price], quantity: row[:quantity], name: product_t.name, sku: sku_t)
										end
									else
										item_t = QuotationProduct.create(product: product_t, 
																										 price: row[:price], 
																										 quantity: row[:quantity], 
																										 quotation: quotation_t, 
																										 name: product_t.name, 
																										 sku: sku_t)
									end
									quotation_t.update(total: quotation_t.total_retail)
								end
							else
								file_errors.push(i+1)
							end
						rescue Exception => e 
							file_errors.push(i+1)
						end
					end
					i += 1
				end
				return quotations.uniq, true, file_errors
			end
		end

		def self.load_oc_retail(file, current_user)
			if !(spreadsheet = User.open_spreadsheet(file))
				return [], false, [-2]
			end
			headers = []
			spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
			headers_required = ["RETAIL", "NRO_F12", "NRO_OC", "FECHA_EMISION_OC", "FECHA_DESPACHO_PACTADA", "RUT", "NOM_COMPRADOR", "TELEFONO_CONTACTO", 
				"NOM_RECEPTOR", "DIRECCION_RECEPTOR", "COMUNA_RECEPTOR", "CIUDAD_RECEPTOR", "EMAIL", "OBSERVACION", "UPC", "SKU", "DESCRIPCION", 
				"UNIDADES", "PRECIO_COSTO", "FECHA_REPARTO_CLIENTE", "MODELO_SKU", "NRO_LOCAL", "LOCAL", "EMPAQUES", "NRO_PRODUCTO", "DESPACHO"]
				if !headers_required.all? { |e| headers.include?(e) }
					return [], false, [-1]
				else
					file_errors = []
					quotations = []
					i = 0
					spreadsheet.each(retail: 'RETAIL', f12_number: 'NRO_F12', oc_number: 'NRO_OC', created_date: 'FECHA_EMISION_OC', agreed_date: 'FECHA_DESPACHO_PACTADA', rut: 'RUT', name: 'NOM_COMPRADOR', phone: 'TELEFONO_CONTACTO', receiver_name: 'NOM_RECEPTOR', dispatch_address: 'DIRECCION_RECEPTOR', dispatch_commune: 'COMUNA_RECEPTOR', city: 'CIUDAD_RECEPTOR', email: 'EMAIL', observations: 'OBSERVACION', upc: 'UPC', dispatch_date: 'FECHA_REPARTO_CLIENTE', sku: 'SKU', product_name: 'DESCRIPCION', quantity: 'UNIDADES', price: 'PRECIO_COSTO', sku_model: 'MODELO_SKU', branch_name: 'LOCAL', branch_number: 'NRO_LOCAL', packing: 'EMPAQUES', nro_producto: 'NRO_PRODUCTO', dispatch: 'DESPACHO') do |row|
						if i > 0
							begin
								if (retail_t = Retail.find_by('LOWER(name) = ?', row[:retail].try(:downcase))) and row[:created_date].present? and row[:oc_number].present?
									cost_center_t = (retail_t.name == 'Falabella' ? CostCenter.find_by(code: 35) : CostCenter.find_by(code: 48))
									oc_number_t = (row[:oc_number].kind_of?(String) ? row[:oc_number] : row[:oc_number].to_i.to_s)
									customer = Customer.find_by(rut: row[:rut])
									if customer
										customer.update(name: row[:name], phone: row[:phone].to_s, dispatch_address: row[:dispatch_address], dispatch_commune: Commune.find_by(name: row[:dispatch_commune]), email: row[:email])
									else
										customer = Customer.create(rut: row[:rut], name: row[:name], phone: row[:phone].to_s, dispatch_address: row[:dispatch_address], dispatch_commune: Commune.find_by(name: row[:dispatch_commune]), email: row[:email])
									end
									if (quotation_t = Quotation.find_by(oc_number: oc_number_t))
										quotation_t.update(retail: retail_t, f12_number: row[:f12_number], created_at: row[:created_date], agreed_dispatch_date: row[:agreed_date], 
											receiver_name: row[:receiver_name], upc: row[:upc], estimated_dispatch_date: row[:dispatch_date],
											observations: row[:observations], dispatch_city: row[:city],  sale_channel: SaleChannel.find_by(name: 'Retail'), dispatch_value: row[:dispatch],
											rut: row[:rut], name: row[:name], phone: row[:phone].to_s, dispatch_address: row[:dispatch_address], dispatch_commune: Commune.find_by(name: row[:dispatch_commune]), email: row[:email], cost_center: cost_center_t)
									else
										quotation_t = Quotation.create(retail: retail_t, oc_number: oc_number_t, f12_number: row[:f12_number], created_at: row[:created_date], agreed_dispatch_date: row[:agreed_date],
											receiver_name: row[:receiver_name], upc: row[:upc], estimated_dispatch_date: row[:dispatch_date],
											observations: row[:observations], dispatch_city: row[:city], user: current_user, sale_channel: SaleChannel.find_by(name: 'Retail'), dispatch_value: row[:dispatch],
											rut: row[:rut], name: row[:name], phone: row[:phone].to_s, dispatch_address: row[:dispatch_address], dispatch_commune: Commune.find_by(name: row[:dispatch_commune]), email: row[:email], cost_center: cost_center_t)
										quotation_t.to_state('Ingresada')
									end
									quotations << quotation_t
									sku_t = (row[:sku].kind_of?(String) ? row[:sku] : row[:sku].to_i.to_s)
									if (retail_product_t = RetailProduct.find_by(retail: retail_t, tnr: sku_t)) and 
											row[:product_name].present? and 
											row[:quantity].present? and 
											row[:price].present?
										prod_t = retail_product_t.product
										if prod_t and (quotation_prod_t = quotation_t.quotation_products.find_by(product: prod_t, product_order: row[:nro_producto]))
											quotation_prod_t.update(price: row[:price], quantity: row[:quantity], name: row[:product_name], 
												sku_model: row[:sku_model], branch_number: row[:branch_number], branch_name: row[:branch_name], packing: row[:packing], max_quantity: row[:quantity], tnr_retail: sku_t, sku: prod_t.sku)
										elsif prod_t
											quotation_t.quotation_products << QuotationProduct.create(product: prod_t, price: row[:price], quantity: row[:quantity], name: row[:product_name], 
												sku_model: row[:sku_model], branch_number: row[:branch_number], branch_name: row[:branch_name], packing: row[:packing], product_order: row[:nro_producto], dispatch: true, 
												instalation: false, mandatory: false, is_service: false, max_quantity: row[:quantity], tnr_retail: sku_t, sku: prod_t.sku)
										else
											file_errors.push(i+1)
										end
									else
										file_errors.push(i+1)
									end
									quotation_t.update(total: quotation_t.total_retail)
								else
									file_errors.push(i+1)
								end
							rescue Exception => e 
								file_errors.push(i+1)
							end
						end
						i+= 1
					end
				end
				return quotations.uniq, true, file_errors
			end
		end