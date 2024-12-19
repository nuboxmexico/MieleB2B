class EcommerceSaleController < ApplicationController
	protect_from_forgery with: :null_session
	skip_before_action :authenticate_user!
	include ActionController::HttpAuthentication::Token::ControllerMethods
	before_action :authenticate

	api :POST, '/ecommerce_sales.json', 'Método que escribe una venta del ecommerce en MPP.'
	formats ['json']
	param :ecommerce_sales, Array, :desc => 'Ventas del día del ecommerce', :required => true, :missing_message => "Faltan ventas!" do
		param :commune, String, :desc => 'Comuna de despacho de la venta.', :required => true, :missing_message => "Falta comuna de despacho"
		param :sell_date, String, :desc => 'Fecha en que se concretó la venta.', :required => true, :missing_message => "Falta fecha de venta"
		param :total, String, :desc => 'Monto total de la compra', :required => true, :missing_message => "Falta total de la compra"
		param :order, String, :desc => 'Código de compra del ecommerce', :required => true, :missing_message => "Falta número de orden"
		param :products, Array, :desc => "Productos incluidos en la venta", :required => true, :missing_message => "Faltan productos de la venta"  do
			param :tnr, String, :desc => "TNR del producto", :required => true, :missing_message => "Falta TNR de producto"
			param :quantity, String, :desc => "Cantidad del producto", :required => true, :missing_message => "Falta cantidad de producto"
			param :total_product, String, :desc => "Monto total de cada producto", :required => true, :missing_message => "Falta total del producto"
		end
	end
	returns :code => 200 do
		property :created, String, :desc => "Status de la creación de ventas"
	end
	returns :code => 500 do
		property :error, String, :desc => "Mensaje indicando el error"
		property :failed, Array, :desc => "Ventas que no se pudo escribir."
	end
	example "Request: "+Rails.application.secrets.BASE_APP+"/ecommerce_sales.json \n body: {
	'ecommerce_sales':
	[
		{
			'commune': 'Santiago',
			'total': '120391',
			'sell_date': '12/03/2020',
			'order': 'R9182301',
			'products':[
				{
					'tnr': '7006550',
					'quantity': '2',
					'total_product': '2000'
					
				},
				{
					'tnr': '9553030',
					'quantity': '4',
					'total_product': '39921'
					
				}
			]
		}
	]		
}
} \n Salida: {'status': 'ok'} código status 200 \n En caso de error retornará error 500. \n Si no vienen ventas en el body del request, se responde con {'error': 'No tienes Ventas del ecommerce.', 'failed': null} 
\n Si hay ventas que no han podido ser escritas, se retornará un mensaje de error junto a un array con los códigos de orden que han fallado {'error': 'Algunas ventas no se han podido escribir.', 'failed': ['R12313', 'R123132']}"
	def create
		if params[:ecommerce_sales].size > 0
			failed = []
			@success = true
			i = 1
			params[:ecommerce_sales].each do |sale|
				if sale[:products].size > 0
					begin
						sale_t = EcommerceSale.create(commune: Commune.find_by(name: sale[:commune]), total: sale[:total], selled_at: sale[:sell_date], order_code: sale[:order])
						sale[:products].each do |prod|
							QuotationProduct.create(product: Product.find_by(sku: prod[:tnr]), quantity: prod[:quantity], total: prod[:total_product], ecommerce_sale: sale_t)
						end
					rescue Exception => e
						failed.push(sale[:order])
						@success = false
						@message = 'Algunas ventas no se han podido escribir.'
					end
				else
					failed.push(sale[:order])
					@success = false
					@message = 'Algunas ventas no se han podido escribir.'
				end
				i += 1
			end
		else
			@success = false
			@message = 'No tienes Ventas del ecommerce.'
		end
		respond_to do |format|
			if @success
				format.json {render :json => {created: 'ok'}, :status => :ok}
			else
				format.json {render :json => {error: @message, failed: failed}, :status => :internal_server_error }
			end
		end
	end

	api :GET, '/get_stock.json', 'Método que busca el stock de un listado de productos'
	formats ['json']
	param :tnrs, Array, :desc => 'TNRs de productos a consultar', :required => true, :missing_message => "Faltan TNRs!"
	example "Request: "+Rails.application.secrets.BASE_APP+"/get_stock.json \nbody: {'tnrs': ['09563250', '09563210']}
	\nSalida: {'09563250': 20, '09563210': 0} código status 200 \nEn caso de error o que no se envíe el parámetro tnrs en el body retornará error 500 y el error incluído en un hash {'error': 'Hubo un error en el request: Faltan TNRs!'}."
	def get_stock
		respond_to do |format|
			if params[:tnrs].present? and params[:tnrs].size > 0
				response = {}
				Product.where(sku: params[:tnrs], ean: nil).map{|prod| response[prod.sku] = prod.stock}
				format.json {render :json => response, :status => :ok}
			else
				format.json {render :json => {}, :status => :internal_server_error }
			end
		end
	end

	api :POST, '/discount_stock.json', 'Método que descuenta stock a partir de un listado de productos'
	formats ['json']
	param :products, Array, :desc => "Productos incluidos en la venta", :required => true, :missing_message => "Faltan productos de la venta"  do
		param :tnr, String, :desc => "TNR del producto", :required => true, :missing_message => "Falta TNR de producto"
		param :quantity, String, :desc => "Cantidad del producto", :required => true, :missing_message => "Falta cantidad de producto"
	end
	example "Request: "+Rails.application.secrets.BASE_APP+"/discount_stock.json \nbody: {'products': [
		{
			'tnr': '10298301',
			'quantity': '1'
		}
	]}
	\nSalida: {'discounted': 'ok'} código status 200 \nEn caso de error o que no se envíe el parámetro products en el body retornará error 500 y el error incluído en un hash {'error': 'No haz enviado productos para descontar stock.'}."
	def discount_stock
		respond_to do |format|
			if params[:products].present? and params[:products].size > 0
				params[:products].map{ |product| EcommerceSale.discount_stock(product)}
				format.json {render :json => {discounted: 'ok'}, :status => :ok}
			else
				format.json {render :json => {error: 'No haz enviado productos para descontar stock.'}, :status => :internal_server_error }
			end
		end
	end

	api :POST, '/reverse_stock.json', 'Método que repone stock a partir de un listado de productos'
	formats ['json']
	param :products, Array, :desc => "Productos incluidos en la venta", :required => true, :missing_message => "Faltan productos de la venta"  do
		param :tnr, String, :desc => "TNR del producto", :required => true, :missing_message => "Falta TNR de producto"
		param :quantity, String, :desc => "Cantidad del producto", :required => true, :missing_message => "Falta cantidad de producto"
	end
	example "Request: "+Rails.application.secrets.BASE_APP+"/reverse_stock.json \nbody: {'products': [
		{
			'tnr': '10298301',
			'quantity': '1'
		}
	]}
	\nSalida: {'reversed': 'ok'} código status 200 \nEn caso de error o que no se envíe el parámetro products en el body retornará error 500 y el error incluído en un hash {'error': 'No haz enviado productos para reponer stock.'}."
	def reverse_stock
		respond_to do |format|
			if params[:products].present? and params[:products].size > 0
				params[:products].map{ |product| EcommerceSale.reverse_stock(product)}
				format.json {render :json => {reversed: 'ok'}, :status => :ok}
			else
				format.json {render :json => {error: 'No haz enviado productos para reponer stock.'}, :status => :internal_server_error }
			end
		end
	end


	api :POST, '/create_ecommerce_quotation', 'Método que crea una cotización proveniente del Ecommerce B2C.'
	formats ['json']
	param :ecommerce_sale_order, Object, :desc => 'Venta del día del ecommerce', :required => true, :missing_message => 'Falta venta del Ecommerce' do
		param :number, String, :desc => 'numero de la order', :required => true, :missing_message => 'falta numero de order'
		param :sell_date, String, :desc => "fecha de la venta", :required => true, :missing_message => "falta fecha de la venta" 
		param :item_total, String, :desc => "valor total de los productos", :required => true, :missing_message => "falta valor total de los productos" 
		param :shipment_total, Integer, :desc => "valor total del envio", :required => true, :missing_message => "falta valor del envio"
		param :installation_total, Integer, :desc => "valor total de la instalacion", :required => true, :missing_message => "falta valor de la instalacion"
		param :total, String, :desc => 'Monto total de la compra', :required => true, :missing_message => "Falta total de la compra"
		param :document_type, String, :desc => 'Tipo de order de compra(boleta o factura)', :required => true, :missing_message => "Falta tipo de order de compra"
		param :customer, Object, :desc => 'Información de cliente', :required => true, :missing_message => "Falta cliente" do
			param :first_name, String, :desc => "Nombre de cliente", :required => true, :missing_message => "Falta nombre cliente"
			param :last_name, String, :desc =>  "Apellido de cliente",:required => true, :missing_message => "Falta apellido cliente"
			param :email, String, :desc => "Email de cliente",:required => true, :missing_message => "Falta email cliente"
			param :rut,String, :desc => "rut de cliente",:required => true, :missing_message => "Falta rut cliente"
		end 
		param :ship_address, Object, :desc => 'Dirección de envio', :required => true, :missing_message => "Falta dirección de envio" do
			param :rut, String, :desc => 'Rut del cliente en la direccion de envio', :required => true, :missing_message => "Falta rut en la direccion de envio"
			param :first_name, String, :desc => 'Nombre del cliente en la direccion de envio', :required => true, :missing_message => "Falta nombre en la direccion de envio"
			param :last_name, String, :desc => 'Apellido del cliente en la direccion de envio', :required => true, :missing_message => "Falta apellido en la direccion de envio"
			param :address, String, :desc => 'Direccion de envio', :required => true, :missing_message => "Falta direccion de envio"
			param :commune, String, :desc => 'Comuna de envio', :required => true, :missing_message => "Falta Comuna de envio"
			param :city, String, :desc => 'Ciudad de dirección de envio', :required => true, :missing_message => "Falta Ciudad en direccion de envio"
			param :phone, String, :desc => 'Telefono de dirección de envio', :required => true, :missing_message => "Falta Telefono de direccion de envio"
			param :region, Object, :desc => 'Región de dirección de envio', :required => true, :missing_message => "Falta region en direccion de envio" do
				param :name, String, :desc => 'Nombre region de envio', :required => true, :missing_message => "Falta Nombre region de envio"
				param :abbr, String, :desc => 'Abreviatura region de envio', :required => true, :missing_message => "Falta Abreviatura region de envio"
			end
		end
		param :bill_address, Object, :desc => 'Dirección de facturacion', :required => true, :missing_message => "Falta dirección de facturacion" do
			param :rut, String, :desc => 'Rut del cliente en la direccion de facturacion', :required => true, :missing_message => "Falta rut en la direccion de facturacion"
			param :first_name, String, :desc => 'Nombre del cliente en la direccion de facturacion', :required => true, :missing_message => "Falta nombre en la direccion de facturacion"
			param :last_name, String, :desc => 'Apellido del cliente en la direccion de facturacion', :required => true, :missing_message => "Falta apellido en la direccion de facturacion"
			param :address, String, :desc => 'Direccion de facturacion', :required => true, :missing_message => "Falta direccion de facturacion"
			param :commune, String, :desc => 'Comuna de facturacion', :required => true, :missing_message => "Falta Comuna de facturacion"
			param :city, String, :desc => 'Ciudad de dirección de facturacion', :required => true, :missing_message => "Falta Ciudad en direccion de facturacion"
			param :phone, String, :desc => 'Telefono de dirección de facturacion', :required => true, :missing_message => "Falta Telefono de direccion de facturacion"
			param :region, Object, :desc => 'Región de dirección de facturacion', :required => true, :missing_message => "Falta region en direccion de facturacion" do
				param :name, String, :desc => 'Nombre region de facturacion', :required => true, :missing_message => "Falta Nombre region de facturacion"
				param :abbr, String, :desc => 'Abreviatura region de facturacion', :required => true, :missing_message => "Falta Abreviatura region de facturacion"
			end
		end
		param :payment, Object, :desc => 'Pago de order', :required => true, :missing_message => "Falta pago de order" do
			param :payment_state, String, :desc => 'Estado de pago', :required => true, :missing_message => "Falta estado de pago"
			param :tbk_token, String, :desc => 'Transbank Token de pago', :required => true, :missing_message => "Falta Transbank token de pago"
			param :tbk_transaction_id, String, :desc => 'Transbank id de pago', :required => true, :missing_message => "Falta Transbank id de pago"
			param :webpay_data, String, :desc => 'Webpay data de pago', :required => true, :missing_message => "Falta Webpay data de pago"
		end
		param :products, Array, :desc => "Productos incluidos en la venta", :required => true, :missing_message => "Faltan productos de la venta"  do
			param :tnr, String, :desc => "TNR del producto", :required => true, :missing_message => "Falta TNR del producto"
			param :quantity, String, :desc => "Cantidad del producto", :required => true, :missing_message => "Falta cantidad del producto"
			param :instalation, String, :desc => "Instalacion del producto", :required => true, :missing_message => "Falta instalacion del producto"
			param :price, String, :desc => "precio del producto", :required => true, :missing_message => "Falta precio del producto"
		end
	end
	returns :code => 200 do
		property :created, String, :desc => "Se creo con exito la Cotizacion de Ecommerce"
	end
	returns :code => 500 do
		property :error, String, :desc => "Mensaje indicando el error"
	end
	example "Request: "+Rails.application.secrets.BASE_APP+"/create_ecommerce_quotation \n 
	
	body: {
		'ecommerce_sale_order': {
		  'number': 'R736361506',
		  'sell_date': '2022-05-02T17:02:00.349-04:00',
		  'item_total': 1756800,
		  'shipment_total': '19900.0',
		  'total': '1821600.0',
		  'document_type':'ticket'
		  'customer': {
			'first_name': null,
			'last_name': null,
			'email': 'oferusat@gmail.com',
			'rut': null
		  },
		  'ship_address': {
			'rut': '25575477-7',
			'first_name': 'nombre cliente',
			'last_name': 'apellido cliente',
			'address': 'calle cliente',
			'street_type':'calle'
			'commune': 'La Reina',
			'city': 'Santiago',
			'phone': '+(569) 1234 5678',
			'region': {
			  'name': 'Región Metropolitana de Santiago',
			  'abbr': 'RM'
			}
		  },
		  'bill_address': {
			'rut': '25575477-7',
			'first_name': 'nombre cliente',
			'last_name': 'apellido cliente',
			'address': 'calle cliente',
			'street_type':'calle'
			'commune': 'La Reina',
			'city': 'Santiago',
			'phone': '+(569) 1234 5678',
			'region': {
			  'name': 'Región Metropolitana de Santiago',
			  'abbr': 'RM'
			}
		  },
		  'payment': {
			'payment_state': 'paid',
			'tbk_token': '01ab146eea24da6afc6ba092af7f59dead9ff495362f29a4699d62660302a948',
			'tbk_transaction_id': 'O19NvJPD4sVxv4lS2NqaLw1645563246124',
			'webpay_data': '[\'AUTHORIZED\', \'0502\', \'R736361506\', 0, \'7763\', 1821600, \'\', \'1415\', \'VD\', 0, \'2022-05-02T21:01:38.823Z\', \'\', \'TSY\', \'O19NvJPD4sVxv4lS2NqaLw1645563246124\', nil, nil]'
		  },
		  'products': [
			{
			  'tnr': '10684490',
			  'quantity': 1,
			  'instalation': true,
			  'total_product': '1749900.0'
			},
			{
			  'tnr': '10118510',
			  'quantity': 1,
			  'instalation': false,
			  'total_product': '6900.0'
			}
		  ]
		}
	  }
	} \n Salida: {'status': 'ok'} código status 200 \n En caso de error retornará error 500. \n Si no viene la order en el body del request, se responde con {'error': 'No hay Order', 'failed': null} "
	def create_b2c_ecommerce_quotation

		b2c_sale_order = params[:ecommerce_sale_order] 
		success = true
		request_error = ""

		begin 
			# Buscar Cliente y si no Crearlo
			# # La direccion debe cuadrar en tipo de calle y en caso que sea Departamento
			############################################################################################################################
			customer = Customer.find_by(email:b2c_sale_order["customer"]["email"]) rescue nil
			comuna_ship_address = Commune.find_by("lower(name) = ?", b2c_sale_order["ship_address"]["commune"].downcase)
			comuna_bill_address = Commune.find_by("lower(name) = ?", b2c_sale_order["bill_address"]["commune"].downcase)

			if !customer
				rut =  b2c_sale_order["customer"]["rut"]
				name = b2c_sale_order["customer"]["first_name"]
				last_name=""
				second_lastname = ""
				###############################
				split_lastname = b2c_sale_order["customer"]["last_name"].split() rescue ""	
				if split_lastname.length == 1
					last_name = b2c_sale_order["customer"]["last_name"]
				else 
					last_name = split_lastname[0]
					second_lastname = split_lastname[1]
				end
				################################
				phone = b2c_sale_order["ship_address"]["phone"]

				customer = Customer.create!(
					rut: rut, 
					name: name, 
					lastname: last_name, 
					second_lastname: second_lastname, 
					phone: phone,
					email:b2c_sale_order["customer"]["email"], 
					# Personal stuff
					personal_address: b2c_sale_order["ship_address"]["address"],
					personal_address_number: b2c_sale_order["ship_address"]["number"],
					personal_dpto_number: b2c_sale_order["ship_address"]["apartment"],
					personal_address_street_type: b2c_sale_order["ship_address"]["street_type"], 
					personal_commune_id: comuna_ship_address.id,
					# Dispatch stuff 
					dispatch_address: b2c_sale_order["ship_address"]["address"],
					dispatch_address_number: b2c_sale_order["ship_address"]["number"],
					dispatch_dpto_number: b2c_sale_order["ship_address"]["apartment"],
					dispatch_address_street_type: b2c_sale_order["ship_address"]["street_type"],
					dispatch_commune_id: comuna_ship_address.id,
				)
			end
			##########################################################################################################################

			user = User.find_by(email:"ecommercemiele@garagelabs.cl")
			document_type = if b2c_sale_order["document_type"] == "factura" then "factura" else "boleta" end
			core_id_customer = MieleCoreApi.find_customer_by_email_and_rut(b2c_sale_order["customer"]["email"],rut)["data"]["id"] rescue nil
			customer.update!(core_id:core_id_customer)

			###########################################################################################################################
			# Crear Cotizacion 

			quotation_obj = {
				user_id: user.id,
				# Customer
				customer_id: customer.id,
				name: customer.name,
				lastname: customer.lastname,	
				second_lastname: customer.second_lastname,
				email: b2c_sale_order["customer"]["email"],
				rut: b2c_sale_order["customer"]["rut"],
				phone: b2c_sale_order["ship_address"]["phone"],
				mobile_phone: b2c_sale_order["ship_address"]["phone"],

				# Quotation stuff
				document_type: document_type,
				pay_percent: 100,
				paid_ammount: 100,
				currency: "clp",
				dispatch_value: b2c_sale_order["shipment_total"].to_i,
				installation_value: b2c_sale_order["installation_total"],
				total: b2c_sale_order["total"].to_i,
				sale_channel_id: 5, # Canal Ecommerce
				cost_center_id: 14, # Webshop
				project_name: "Ecommerce",
				valid_quotation: true,
				
				# Personal stuff
				personal_address: b2c_sale_order["ship_address"]["address"],
				personal_address_number: b2c_sale_order["ship_address"]["number"],
				personal_dpto_number: b2c_sale_order["ship_address"]["apartment"],
				personal_address_street_type: b2c_sale_order["ship_address"]["street_type"], 
				personal_commune_id: comuna_ship_address.id,

				# Dispatch stuff 
				dispatch_address: b2c_sale_order["ship_address"]["address"],
				dispatch_address_number: b2c_sale_order["ship_address"]["number"],
				dispatch_dpto_number: b2c_sale_order["ship_address"]["apartment"],
				dispatch_address_street_type: b2c_sale_order["ship_address"]["street_type"],
				dispatch_commune_id: comuna_ship_address.id,

				# Instalation stuff
				instalation_address: b2c_sale_order["ship_address"]["address"],
				instalation_address_number: b2c_sale_order["ship_address"]["number"],
				instalation_dpto_number: b2c_sale_order["ship_address"]["apartment"],	
				instalation_address_street_type: b2c_sale_order["ship_address"]["street_type"], 
				instalation_commune_id: comuna_ship_address.id,

				# Businness Stuff
				business_rut: b2c_sale_order["bill_address"]["rut"],
				business_name: b2c_sale_order["bill_address"]["first_name"],
				#business_sector: "",
				billing_address: b2c_sale_order["bill_address"]["address"],
				billing_address_number: b2c_sale_order["bill_address"]["number"],
				billing_dpto_number: b2c_sale_order["bill_address"]["apartment"],
				billing_address_street_type: b2c_sale_order["bill_address"]["street_type"],
				billing_commune_id: comuna_bill_address.id
			}

			quotation = Quotation.create!(quotation_obj)

			###########################################################################################################################
			# Asociar Quotation a Ecommerce Sale
			
			ecommerce_sale = EcommerceSale.find_by(order_code:b2c_sale_order["number"])
			ecommerce_sale.update!(quotation_id:quotation.id)

			###########################################################################################################################
			# Crear pago

			payment_obj = {
				quotation_id: quotation.id,
				description: "Comprada Realizada a través del Ecommerce B2C de MIELE CL",
				ammount: b2c_sale_order["total"].to_i,
				pay_date: b2c_sale_order["sell_date"],
				verified: true,
				payment_type: "webpay",
				tbk_transaction_id: b2c_sale_order["tbk_transaction_id"],
				tbk_token: b2c_sale_order["tbk_token"],
				webpay_data: b2c_sale_order["webpay_data"],
				state: "complete"#,
				#miele_tx_code: "MPP1665685409",
			}

			payment = Payment.create!(payment_obj)

			###########################################################################################################################
			# Asociar quotation Productos 
			
			b2c_sale_order["products"].each do |product|

				if product["tnr"] == "PEM"
					quotation.update!(activation_confirm: true) # HOME PROGRAM
				end 

				product_b2b = Product.find_by(sku:product["tnr"])

				quotation.quotation_products << QuotationProduct.new(
					quantity:  product["quantity"],
					price:     product["price"],
					instalation: product["instalation"],
					product_id: product_b2b.id,
					name:      product_b2b.name,
					sku:       product_b2b.sku,
					mandatory: product_b2b.mandatory,
					dispatch:  product_b2b.dispatch,
					is_service: product_b2b.is_service	
				)
			end

			###########################################################################################################################
			# Cambiar estado de Cotizacion a "En curso", para que sea validada directamente en finanzas
			
			new_state = QuotationState.find_by(name: 'En curso')
			quotation.update!(quotation_state:new_state)
			quotation.reload

		rescue StandardError => e
			request_error = e
			success = false
		end

		respond_to do |format|
			if success
				format.json {render :json => {created: 'ok', folio_b2b: quotation.code}, :status => :ok}
			else
				format.json {render :json => {created: 'fail',:request_error => request_error}, :status => :internal_server_error}
			end
		end

	end
end