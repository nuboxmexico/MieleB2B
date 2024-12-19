require 'faraday'

class Customer < ApplicationRecord

  KEY_CHANGER = {
    "name" => "names",
    "lastname" => "lastname",
    "second_lastname" => "surname",
    "email" => "email",
    "phone" => "phone",
	"mobile_phone" => "cellphone",
    "rut" => "rut",
	"personal_address_street_type" => "street_type",
    "personal_address" => "street_name",
    "personal_address_number" => "ext_number",
    "personal_dpto_number" => "int_number",
    "business_name" => "tradename",
	"business_name" => "business_name",
    "business_sector" => "commercial_business",
	"billing_address_street_type" => "street_type_fn",
    "billing_address" => "street_name_fn",
    "billing_address_number" => "int_number_fn",
    "billing_dpto_number" => "ext_number_fn",
	"business_rut" => "rfc"
  }

  KEY_SELECTOR = ["business_rut","name", "lastname", "second_lastname", "email", "phone", "mobile_phone", "rut", "personal_address", "personal_address_number", "personal_address_street_type", "personal_dpto_number", "business_name", "business_sector", "billing_address", "billing_address_number", "billing_address_street_type", "billing_dpto_number"]
	STREET_TYPE_SELECTOR = ["Calle", "Avenida", "Pasaje", "Diagonal"].freeze

	belongs_to :dispatch_commune  , class_name: "Commune"
	belongs_to :personal_commune  , class_name: "Commune"
	belongs_to :instalation_commune  , class_name: "Commune"
	belongs_to :billing_commune  , class_name: "Commune"
	belongs_to :user
	has_many :quotations, dependent: :destroy

	#validates :email, uniqueness: { message: "ya existe"}
	#validates :rut, uniqueness: { message: "ya existe"}			# los costumers de los proyectos no tienen rut
	validates :name,  presence: { message: "no puede estar vacío"}
	#validates :rut,  presence: { message: "no puede estar vacío"}	# los costumers de los proyectos no tienen rut
	validates :email,  presence: { message: "no puede estar vacío"}
	#validates :phone,  presence: { message: "no puede estar vacío"}
	#validates :personal_address_street_type, inclusion: STREET_TYPE_SELECTOR
	#validates :dispatch_address_street_type, inclusion: STREET_TYPE_SELECTOR

	before_save { self.rut.downcase! unless self.rut.nil? }			# los costumers de los proyectos no tienen rut
	before_save { self.email.downcase! unless self.email.nil? }

	def customer_name
		return "#{self.try(:name).to_s} #{self.try(:lastname).to_s} #{self.try(:second_lastname).to_s}"
	end

	def check_partner(quotation, user)
		if !self.quotations and !self.user
			self.update(quotation: quotation, user: user, expiration_date: (Date.today+180.days))
			quotation.update(referred_user: self.user)
		end
	end

	def self.check_expiration_partner
		Customer.where(expiration_date: Date.today)
						.update(user: nil, expiration_date: nil)
	end

	def update_core_id
		response_data = MieleCoreApi.find_customer_by_email_and_rut(self.email,self.rut)
		@response_data_project = MieleCoreApi.find_project_customer_by_rfc(self.business_rut) unless self.business_rut.blank?
		if @response_data_project && @response_data_project['project_customer']
			return self.update(core_id: @response_data_project['project_customer']['id'],
								customer_project: true)
		else
			if !response_data.blank?
				self.update(core_id: response_data['data']['id'], customer_project: false)
				return response_data['data']
			else 
				return false 
			end
		end
	end

	def replicate_in_core(observations=nil, quotation_params=nil)
		if (self.email =~ URI::MailTo::EMAIL_REGEXP).nil? || !self.core_id.nil? || self.update_core_id
			return false 
		else
			unless self.rut
				customer_project_data = {
					nombre_inmobiliaria:  quotation_params["real_state_name"].blank? ? "" : quotation_params["real_state_name"],
					business_name_project:  quotation_params["business_name"].blank? ? "" : quotation_params["business_name"],
					rfc_project:  quotation_params["business_rut"].blank? ? "" : quotation_params["business_rut"],
					commercial_business_project:  quotation_params["business_sector"].blank? ? "" : quotation_params["business_sector"],
					nombre_proyecto:  quotation_params["project_name"].blank? ? "" : quotation_params["project_name"],
					street_type_project:  quotation_params["dispatch_address_street_type"].blank? ? "" : quotation_params["dispatch_address_street_type"],
					street_name_project:  quotation_params["dispatch_address"].blank? ? "" : quotation_params["dispatch_address"],
					state_project:  quotation_params["dispatch_commune_id"].blank? ? "" : Commune.find(quotation_params["dispatch_commune_id"].to_i)["core_id"],
					ext_number_project:  quotation_params["dispatch_address_number"].blank? ? "" : quotation_params["dispatch_address_number"],
					reference_project:  quotation_params["observations"].blank? ? "" : quotation_params["observations"],
					nombre_contacto:  quotation_params["name"].blank? ? "" : quotation_params["name"],
					last_name_contact:  quotation_params["lastname"].blank? ? "" : quotation_params["lastname"],
					surname_contact:  quotation_params["second_lastname"].blank? ? "" : quotation_params["second_lastname"],
					email_contact:  quotation_params["email"].blank? ? "" : quotation_params["email"],
					street_type_contact:  quotation_params["personal_address_street_type"].blank? ? "" : quotation_params["personal_address_street_type"],
					state_contact:  quotation_params["personal_commune_id"].blank? ? "" : Commune.find(quotation_params["personal_commune_id"].to_i)["core_id"],
					street_name_contact:  quotation_params["personal_address"].blank? ? "" : quotation_params["personal_address"],
					ext_number_contact:  quotation_params["personal_address_number"].blank? ? "" : quotation_params["personal_address_number"],
					int_number_contact:  quotation_params["personal_dpto_number"].blank? ? "" : quotation_params["personal_dpto_number"],
					phone_contact:  quotation_params["phone"].blank? ? "" : quotation_params["phone"],
					cell_phone_contact:  quotation_params["mobile_phone"].blank? ? "" : quotation_params["mobile_phone"],
					code_project: quotation_params["code"].blank? ? "" : quotation_params["code"],
					b2b_id: quotation_params["quotation_id"].blank? ? "" : quotation_params["quotation_id"].to_s
				}
				if response = MieleCoreApi.create_project_customer(customer_project_data)
					self.update(customer_project: true, core_id: response['id'])
					return true
				else
					return false
				end
			else
				prebuilt_attributes = {
					#"country_id" => 2,		# MieleCoreApi
					"country" => "CL",		# MieleTicketApi
					"state" => self.personal_commune.try(:core_id),
					"state_fn"  => self.billing_commune.try(:core_id), 
					"email_fn" => self.email,
					"reference" => observations 
				}
		
				customer_hash = self.as_json
									.slice(*KEY_SELECTOR)
									.transform_keys{|k,v| KEY_CHANGER[k] }
									.merge(prebuilt_attributes)
									.reject{|k,v| v.blank?}
		
				if (response_data = MieleTicketApi.create_customer(customer_hash))
					replicate_additional_address_in_core(response_data['id'], ["Despacho", "Instalación"])
					self.update( core_id: response_data['id'], customer_project: false )
					return true
				else
					return false
				end
			end
		end
	 
	end

	def replicate_additional_address_in_core(customer_id, options)

		return false if (options - ["Despacho", "Instalación"]).any?

		additional_address = get_formatted_additional_addresses
		additional_address.select!{|attributes| options.include? attributes['name']}

		additional_address.map! do |address|
      address_data = {
        "country_id" => "2"
      }.merge(address)
       .reject{|k,v| v.blank?}

			MieleCoreApi.add_additional_address_to_customer(customer_id, address_data)
		end
	end

	def replicate_products_in_core_id(products_core_ids, quotation_id, quotation_number)
    	MieleCoreApi.assign_product_to_customer(self.core_id, products_core_ids, quotation_id, quotation_number)
	end

	def update_in_core(observations, quotation_params=nil)
		if (self.email =~ URI::MailTo::EMAIL_REGEXP).nil? || self.core_id.nil?
			return false 
		else 
			unless self.rut
				customer_project_data = {
					nombre_inmobiliaria:  quotation_params["real_state_name"].blank? ? "" : quotation_params["real_state_name"],
					business_name_project:  quotation_params["business_name"].blank? ? "" : quotation_params["business_name"],
					rfc_project:  quotation_params["business_rut"].blank? ? "" : quotation_params["business_rut"],
					commercial_business_project:  quotation_params["business_sector"].blank? ? "" : quotation_params["business_sector"],
					nombre_proyecto:  quotation_params["project_name"].blank? ? "" : quotation_params["project_name"],
					street_type_project:  quotation_params["dispatch_address_street_type"].blank? ? "" : quotation_params["dispatch_address_street_type"],
					street_name_project:  quotation_params["dispatch_address"].blank? ? "" : quotation_params["dispatch_address"],
					state_project:  quotation_params["dispatch_commune_id"].blank? ? "" : Commune.find(quotation_params["dispatch_commune_id"].to_i)["core_id"],
					ext_number_project:  quotation_params["dispatch_address_number"].blank? ? "" : quotation_params["dispatch_address_number"],
					reference_project:  quotation_params["observations"].blank? ? "" : quotation_params["observations"],
					nombre_contacto:  quotation_params["name"].blank? ? "" : quotation_params["name"],
					last_name_contact:  quotation_params["lastname"].blank? ? "" : quotation_params["lastname"],
					surname_contact:  quotation_params["second_lastname"].blank? ? "" : quotation_params["second_lastname"],
					email_contact:  quotation_params["email"].blank? ? "" : quotation_params["email"],
					street_type_contact:  quotation_params["personal_address_street_type"].blank? ? "" : quotation_params["personal_address_street_type"],
					state_contact:  quotation_params["personal_commune_id"].blank? ? "" : Commune.find(quotation_params["personal_commune_id"].to_i)["core_id"],
					street_name_contact:  quotation_params["personal_address"].blank? ? "" : quotation_params["personal_address"],
					ext_number_contact:  quotation_params["personal_address_number"].blank? ? "" : quotation_params["personal_address_number"],
					int_number_contact:  quotation_params["personal_dpto_number"].blank? ? "" : quotation_params["personal_dpto_number"],
					phone_contact:  quotation_params["phone"].blank? ? "" : quotation_params["phone"],
					cell_phone_contact:  quotation_params["mobile_phone"].blank? ? "" : quotation_params["mobile_phone"],
					code_project: quotation_params["code"].blank? ? "" : quotation_params["code"],
					b2b_id: quotation_params["quotation_id"].blank? ? "" : quotation_params["quotation_id"].to_s
				}
				unless MieleCoreApi.create_project_customer(customer_project_data)
					return false 
				else
					self.update(customer_project: true)
					return true
				end

			else
				prebuilt_attributes = {
						"state" => self.personal_commune.try(:core_id),
						"state_fn"  => self.billing_commune.try(:core_id),
						"email_fn" => self.email,
						"reference" => observations  
					} 

				customer_data = self.as_json
									.slice(*KEY_SELECTOR)
									.transform_keys{|k,v| KEY_CHANGER[k] }
									.merge(prebuilt_attributes)
									.reject{|k,v| v.blank?}

				unless MieleCoreApi.update_customer(self.core_id, customer_data)
					return false
				else
					self.update(customer_project: false)
					update_additional_address_in_core
					return true
				end
			end
		end
	end

	def update_additional_address_in_core
		response_data = MieleCoreApi.find_customer_by_id(self.core_id)['data']

		additional_address = get_formatted_additional_addresses

		additional_address_core_ids = response_data['additional_addresses']
			.select{|address| ["Instalación", "Despacho"].include?(address['name']) }
			.map{|address| { address['name'] => address['id'] } }
			.reduce(Hash.new, :merge)

		additional_address_core_ids.each do |address_type, address_core_id|
      address_data = additional_address.find{ |address| address['name'] == address_type}
                                       .reject{|k,v| v.blank?}

      MieleCoreApi.update_additional_customer_address(address_core_id, address_data)

			additional_address.delete_if{ |address| address['name'] == address_type }
		end

		options = ["Instalación", "Despacho"] - additional_address_core_ids.keys

		return true if options.empty?

		replicate_additional_address_in_core(self.core_id, options) unless options.empty?

	end

	def get_formatted_additional_addresses

		dispatch_attributes = {
			"name" => "Despacho",
			"state" => self.dispatch_commune.try(:core_id),
			"street_type" => self.dispatch_address_street_type,
			"street_name" => self.dispatch_address,
			"ext_number" => self.dispatch_address_number,
			"int_number" => self.dispatch_dpto_number
		}

		installation_attributes = {
			"name" => "Instalación",
			"state" => self.instalation_commune.try(:core_id),
			"street_type" => self.instalation_address_street_type,
			"street_name" => self.instalation_address,
			"ext_number" => self.instalation_address_number,
			"int_number" => self.instalation_dpto_number
		}

		[dispatch_attributes, installation_attributes]
	end

end
