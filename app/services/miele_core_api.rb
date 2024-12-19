class MieleCoreApi
  def self.find_customer_by_email(customer_email)
    response = api_connection.get do |req|
      req.url '/api/v1/customers/no_id'
      req.body = {
        email: customer_email
      }.to_json
    end

    return process_response(response,__method__)
  end

  def self.find_customer_by_email_and_rut(customer_email,rut)
    body = {}
    if !rut.blank?
      body = {
        email: customer_email,
        rut: rut
      }
    else
      body = {
        email: customer_email
      } 
    end
    
    response = api_connection.get do |req|
      req.url '/api/v1/customers/no_id'
      req.body = body.to_json
    end

    return process_response(response,__method__)
  end


  
  def self.find_project_customer_by_rfc(customer_rfc)
    response = api_connection.get do |req|
      req.url '/api/v1/project_customers/no_id'
      req.body = {
        rfc: customer_rfc
      }.to_json
    end

    return process_response(response,__method__)
  end

  def self.find_project_by_code(project_code)
    response = api_connection.get do |req|
      req.url '/api/v1/projects/no_id'
      req.body = {
        code: project_code
      }.to_json
    end

    return process_response(response,__method__)
  end

  def self.create_unit_real_state(project_id , units_hash)
    response = api_connection.post do |req|
      req.url "api/v1/projects/#{project_id}/unit_real_state"
      req.body = units_hash.to_json
    end

    return process_response(response,__method__)
  end

  def self.find_customer_by_id(customer_id)
    response = api_connection.get do |req|
      req.url "/api/v1/customers/#{customer_id}"
    end

    return process_response(response,__method__)
  end

  def self.create_project_customer(project_customer_hash)
    response = api_connection.post do |req|
      req.url '/api/v1/project_customers'
      req.body = project_customer_hash.to_json
    end

    return process_response(response,__method__)
  end

  def self.create_customer(customer_hash)
    response = api_connection.post do |req|
      req.url '/api/v1/customers'
      req.body = customer_hash.to_json
    end

    return process_response(response,__method__)
  end

  def self.create_service(customer_id, service_hash)
    response = api_connection.post do |req|
      req.url "/api/v1/customers/#{customer_id}/create_service"
      req.body = service_hash.to_json
    end

    return process_response(response,__method__)
  end

  def self.update_product(customer_id, product_hash)
    response = api_connection.patch do |req|
      req.url "/api/v1/customers/#{customer_id}/update_product"
      req.body = product_hash.to_json
    end

    return process_response(response,__method__)
  end

  def self.update_customer(customer_id, customer)
    response = api_connection.patch do |req|
      req.url "/api/v1/customers/#{customer_id}"
      req.body = customer.to_json
      
    end

    return process_response(response,__method__)
  end

  def self.add_additional_address_to_customer(customer_id, address)
    response = api_connection.post do |req|
      req.url '/api/v1/customersAdditionalAddress'
      req.body = {customer_id: customer_id.to_s}.merge(address).to_json
    end

    return process_response(response,__method__)
  end

  def self.update_additional_customer_address(address_id, additional_address)
    response = api_connection.patch do |req|
      req.url "/api/v1/customersAdditionalAddress/#{address_id}"
      req.body = additional_address.to_json
    end

    return process_response(response,__method__)
  end

  def self.assign_product_to_customer(customer_id, products_id, quotation_id, quotation_number)
    products_id = products_id.split(",")
    var = 0  
    products = []
    while var <  products_id.length 
      aux = {core_id: products_id[var],
             state: products_id[var+1],
             dispatch: products_id[var+2],
             instalation: products_id[var+3],
             home_program: products_id[var+4],
             b2b_ean: products_id[var+5]
          }
      products.push(aux)
      var += 6
    end
    response = api_connection.post do |req|
      req.url "/api/v1/customers/#{customer_id}/create_product"
      req.body = {
        products_object: products,
        quotation_id: quotation_id.to_s,
        quotation_number: quotation_number
      }.to_json
    end

    return process_response(response,__method__)
  end

  def self.find_product_by_tnr(product_tnr, reduce = nil)
    response = api_connection.get do |req|
      req.url '/api/v1/products_by_tnr'
      body = {}
      body[:tnrs] =  product_tnr
      body[:reduce] =  "true" if reduce
      req.body = body.to_json
    end

    return process_response(response,__method__)
  end

  def self.update_names_communes
    c1 = Commune.where(name: "Camiña")
    c1.update(name:"Camina")
    c2 = Commune.where(name: "Ollagüe")
    c2.update(name:"Ollague") 
    c3 = Commune.where(name: "Paihuano")
    c3.update(name:"Paiguano") 
    c4 = Commune.where(name: "Rinconada de los Andes")
    c4.update(name:"Rinconada")
    c4 = Commune.where(name: "La Calera")
    c4.update(name:"Calera")  
    c5 = Commune.where(name: "Coínco")
    c5.update(name:"Coinco")
    c6 = Commune.where(name: "San Francisco de Mostazal")
    c6.update(name:"Mostazal") 
    c6 = Commune.where(name: "Requínoa")
    c6.update(name:"Requinoa") 
    c7 = Commune.where(name: "San Vicente de Tagua Tagua")
    c7.update(name:"San Vicente")
    c8 = Commune.where(name: "Marchigüe")
    c8.update(name:"Marchihue")
    c9 = Commune.where(name: "San Javier de Loncomilla")
    c9.update(name:"San Javier") 
    c10 = Commune.where(name: "San Pedro de la Paz")
    c10.update(name:"San Pedro De La Paz") 
    c11 = Commune.where(name: "Cañete")
    c11.update(name:"Canete")  
    c12 = Commune.where(name: "Los Álamos")
    c12.update(name:"Los Alamos")  
    c13 = Commune.where(name: "Tirúa")
    c13.update(name:"Tirua")
    c14 = Commune.where(name: "Los Ángeles")
    c14.update(name:"Los Angeles") 
    c15 = Commune.where(name: "Cholchol")
    c15.update(name:"Chol Chol") 
    c16 = Commune.where(name: "Cochamó")
    c16.update(name:"Cochamo") 
    c17 = Commune.where(name: "Queilén")
    c17.update(name:"Queilen")
    c18 = Commune.where(name: "San Juan de la Costa")
    c18.update(name:"San Juan De La Costa") 
    c19 = Commune.where(name: "Hualaihué")
    c19.update(name:"Hualaihue")  
    c20 = Commune.where(name: "O'Higgins")
    c20.update(name:"O’Higgins")
    c21 = Commune.where(name: "Río Ibáñez")
    c21.update(name:"Río Ibanez")  
    c22 = Commune.where(name: "Cabo de Hornos")
    c22.update(name:"Cabo De Hornos") 
    c23 = Commune.where(name: "Torres del Paine")
    c23.update(name:"Torres Del Paine") 
    c24 = Commune.where(name: "Maipú")
    c24.update(name:"Maipu")  
    c25 = Commune.where(name: "Peñalolén")
    c25.update(name:"Penalolén")   
    c26 = Commune.where(name: "San José De Maipo")
    c26.update(name:"San Jose De Maipo")
    c27 = Commune.where(name: "Alhué")
    c27.update(name:"Alhue")
    c28 = Commune.where(name: "Máfil")
    c28.update(name:"Mafil")
    c29 = Commune.where(name: "Curaco de Vélez")
    c29.update(name:"Curaco De Vélez")
    c30 = Commune.where(name: "Quilpué")
    c30.update(name:"Quilpue")
    c31 = Commune.where(name: "Quilpué")
    c31.update(name:"Quilpue")
    c32 = Commune.where(name: "Ránquil")
    c32.update(name:"Ranquil")  
    c33 = Commune.where(name: "Ñiquén")
    c33.update(name:"Niquén")
  end

  def self.get_administrative_demarcations
    response = api_connection.get do |req|
      req.url '/api/v1/administrative_demarcations?keywords=CL'
    end

    final = update_administrative_demarcations(process_response(response,__method__))
  end

  def self.update_administrative_demarcations(core_demarcations) 
    success = 0
    core_demarcations["data"].each do |commune_core,index|
      commune_local = Commune.where(name: commune_core["admin_name_3"]).take
      if commune_local
        if commune_local.update(core_id: commune_core["id"])
          success = success+1
        end
      end
    end
    return "Se actualizaron #{success} registros."
  end

  # Request a la api de Miele Core para obtener los Tnr de los productos del core y verificar cuales se encuentran actualmente en el B2C, para poder sincronizarlos 
  def self.getTnrProductsFromMieleCore(country,platform)
    response = api_connection.get do |req|
        req.url '/api/v1/tnr_products_filter_by_country_and_platform'
        req.params['country'] = country
        req.params['platform'] = platform
    end
  
    return process_response(response,__method__)
  end

  # Request a la api de Miele core, para obtener el stock de products por TNRs 
  def self.fetch_stock(skus)
    response = api_connection.get do |req|
      req.url "/api/v1/get_stock_of_products"
      req.body = {
        country_iso:"CL",
        tnrs: skus
      }.to_json
      req.options.timeout = 120  
    end
    return process_response(response,__method__)
  end

  # Request a la api de Miele core, despues de realizar una cotización, para que descuente el stock en base a una lista de productos
  def self.discount_stock_products_on_miele_core(quotation_products)
    response = api_connection.patch do |req|
      req.url "/api/v1/discount_stock_of_products"
      req.body = {
        country_iso:"CL",
        products: quotation_products.map{|p| {tnr:p.sku, quantity: p.quantity.to_i}}
      }.to_json
    end
    return process_response(response,__method__)
  end

  # Request a la api de Miele core, despues de un fallo, de no completar un pago en una cotizacion, etc. Se restaura el valor stock anteriormente descontado a la lista de productos
  def self.restore_stock_products_on_miele_core(quotation_products)
    response = api_connection.patch do |req|
      req.url "/api/v1/restore_stock_of_products"
      req.body = {
        country_iso:"CL",
        products: quotation_products.map{|p| {tnr:p.sku, quantity: p.quantity.to_i}}
      }.to_json
    end
    return process_response(response,__method__)
  end

  private
   
  def self.api_connection
    return Faraday.new(
      url: Rails.application.secrets.miele_core_api[:url_base],
      headers: request_headers
    )
  end

  def self.request_headers
    return {
      'Authorization' => "Token token=#{Rails.application.secrets.miele_core_api[:token]}",
      'Content-Type' => 'application/json'
    }
  end

  def self.process_response(response,called_method)
    if response.status == 200
      return JSON.parse(response.body)
    else
      Rails.logger.error "[ERROR SENDED REQUEST IN Miele_core_api File]: Called Method '#{called_method}' with response: #{response.body}"
      nil
    end
  end
end