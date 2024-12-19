class Api::V1::CustomersController < ApplicationController
    protect_from_forgery with: :null_session
    skip_before_action :authenticate_user!
    before_action :authenticate
    before_action :set_customer, only: [:get_customer_quotations, :create_or_update]

    api :GET, "/v1/customers/get_quotations", "Finaliza un grupo de envío despachado"    
    param :email, String, :desc => "email del customer"
    def get_customer_quotations
        response = {}
        response["data"] = @customer.nil? ? {error: "No se ha encontrado cliente con ese id."} : @customer
        code = @customer.nil? ? :not_found : :ok
        quotations = @customer.quotations.map{|q| {quotation: q,
                                                    quotation_products: q.quotation_products.map{|p| p.detail_quotation_products},
                                                    quotation_state: q.quotation_state}} unless @customer.nil? 
        
        
        if !quotations.nil?
            @details = [] 
            quotation_not_empty = []
            quotations.each do |q|
                buenos = 0
                q[:quotation_products].each do |qp|
                    if qp.length != 0
                        buenos = buenos + 1 
                    end
                end
                if buenos == q[:quotation_products].length
                    quotation_not_empty.push(q)
                end
                
            end
            quotations = quotation_not_empty.reverse
            quotations.each do |q|
                q[:quotation_products].each do |qp|
                    qp.each do |d|
                        services = []
                        services.push("DESP") if d["dispatch"]
                        services.push("INST") if d["instalation"]
                        services.push("HPRO") if d["home_program"]
                        services = services.join(" - ")
                        aux = {id: d["id"],
                            name: d["name"],
                            state: d["state"],
                            tnr: d["tnr"],
                            serial_id: d["serial_id"],
                            services: services,
                            admission_date: d["admission_date"],
                            core_id: d["core_id"]}
                        @details.push(aux)
                    end
                end
                q["quotation_products"] = @details
                @details = [] 
            end
        end
        
        if !quotations.nil?
			response["data"] = quotations
            response = response.as_json
            response['data'].each do |q|
                b2c_order_number = EcommerceSale.find_by(quotation_id:q["quotation"]["id"]).order_code rescue nil
                q["quotation"]['b2c_order_number'] = b2c_order_number       
            end
			render json:  response.to_json, status: code
        else
            render json:  response.to_json, status: code
        end
    end 


    api :POST, "/v1/customers", "Crea un cliente doméstico final desde Tickets"
    param :name, String, :desc => "Nombre del cliente", :required => true
    param :lastname, String, :desc => "Primer apellido", :required => true
    param :second_lastname, String, :desc => "Segundo apellido", :required => true
    param :rut, String, :desc => "RUT", :required => true
    param :email, String, :desc => "Correo electrónico", :required => true
    param :phone, String, :desc => "Teléfono fijo", :required => true
    param :mobile_phone, String, :desc => "Celular", :required => true
    param :personal_address, String, :desc => "Nombre de calle de dirección personal", :required => true
    param :personal_address_number, String, :desc => "Número de dirección personal", :required => true
    param :personal_dpto_number, String, :desc => "Número de departamento de dirección personal", :required => true
    param :personal_address_street_type, String, :desc => "['Calle', 'Avenida', 'Pasaje', 'Diagonal']", :required => true
    param :personal_commune_id, String, :desc => "ID de la comuna de la dirección personal (el mismo de Core)", :required => true
    param :dispatch_address, String, :desc => "Nombre de calle de dirección de despacho"
    param :dispatch_address_number, String, :desc => "Número de dirección de despacho"
    param :dispatch_dpto_number, String, :desc => "Número de departamento de dirección de despacho"
    param :dispatch_address_street_type, String, :desc => "['Calle', 'Avenida', 'Pasaje', 'Diagonal']", :required => true
    param :dispatch_commune_id, String, :desc => "ID de la comuna de la dirección de despacho (el mismo de Core)"
    param :instalation_address, String, :desc => "Nombre de calle de dirección de instalación"
    param :instalation_address_number, String, :desc => "Número de dirección de instalación"
    param :instalation_dpto_number, String, :desc => "Número de departamento de dirección de instalación"
    param :instalation_address_street_type, String, :desc => "['Calle', 'Avenida', 'Pasaje', 'Diagonal']"
    param :instalation_commune_id, String, :desc => "ID de la comuna de la dirección de instalación (el mismo de Core)"
    param :billing_address, String, :desc => "Nombre de calle de dirección de facturación"
    param :billing_address_number, String, :desc => "Número de dirección de facturación"
    param :billing_dpto_number, String, :desc => "Número de departamento de dirección de facturación"
    param :billing_address_street_type, String, :desc => "['Calle', 'Avenida', 'Pasaje', 'Diagonal']"
    param :billing_commune_id, String, :desc => "ID de la comuna de la dirección de facturación (el mismo de Core)"
    param :business_name, String, :desc => "Razón social de empresa en caso de factura"
    param :business_sector, String, :desc => "Giro comercial de empresa en caso de factura"
    param :business_rut, String, :desc => "RUT de empresa en caso de factura"

    def create_or_update
        params_customer = customer_params
        params_with_id = [ 'personal_commune_id', 'dispatch_commune_id', 'instalation_commune_id', 'billing_commune_id' ]
        params_with_id.each do |p|
            if params_customer[p]
                commune_b2b = Commune.find_by(core_id: params_customer[p])
                params_customer[p] = commune_b2b&.id
            end
        end
        if @customer
            if @customer.update(params_customer)
                render json: @customer.as_json, status: :ok
            else
                render json: { error: "No se pudo actualizar el cliente" }, status: :internal_server_error
            end
        else
            if customer = Customer.create(params_customer)
                customer.update(customer_project: false)
                render json: customer.as_json, status: :ok
            else
                render json: { error: "No se pudo crear el cliente" }, status: :internal_server_error
            end
        end
    end

    private

    def set_customer
        @customer = Customer.find_by(email: params[:email])
    end

    def customer_params
        params.require(:customer).permit(
            :name,
            :lastname,
            :second_lastname,
            :rut,
            :email,
            :phone,
            :mobile_phone,
            :personal_address,
            :personal_address_number,
            :personal_dpto_number,
            :personal_address_street_type,
            :personal_commune_id,
            :dispatch_address,
            :dispatch_address_number,
            :dispatch_dpto_number,
            :dispatch_address_street_type,
            :dispatch_commune_id,
            :instalation_address,
            :instalation_address_number,
            :instalation_dpto_number,
            :instalation_address_street_type,
            :instalation_commune_id,
            :billing_address,
            :billing_address_number,
            :billing_dpto_number,
            :billing_address_street_type,
            :billing_commune_id,
            :business_name,
            :business_sector,
            :business_rut
        )
    end
end
