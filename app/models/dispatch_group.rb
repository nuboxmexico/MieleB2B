class DispatchGroup < ApplicationRecord
  include AbstractController::Rendering
  belongs_to :quotation
  belongs_to :state, class_name: 'QuotationState', foreign_key: 'quotation_state_id'

  has_many :product_in_dispatch_groups, dependent: :destroy
  has_many :detail_quotation_products
  has_many :quotation_products_auxes, dependent: :destroy
  has_many :products, through: :product_in_dispatch_groups
  has_many :dispatch_guides, dependent: :destroy
  has_many :notes, class_name: 'DispatchNote', dependent: :destroy

  enum reception_type: [
    :acepted_reception_by_customer, 
    :acepted_reception_by_courier,
    :partial_reception,
    :pending_reception 
  ]

  enum installation_confirm: [
    :confirm,
    :pending
  ]

  accepts_nested_attributes_for :product_in_dispatch_groups
  accepts_nested_attributes_for :notes

  after_create :set_dispatch_notes
  after_update :check_reception_type, if: -> { partial_reception? }
  before_update :add_installation_note, if: -> { installation_confirm_changed? }
  before_update :notify_state_change, if: -> { quotation_state_id_changed? }

  scope :to_install_state, -> { joins(:state).where(quotation_states: {name: 'Por instalar'}) }

  before_create :set_dispatch_uuid

  def set_dispatch_uuid
    self.dispatch_uuid = SecureRandom.uuid
  end

  @@selected_detail_quotation_products = 0
  def self.create_dispatch_service_in_core(dispatch_group)
    begin
      quotation = dispatch_group.quotation
      customer = MieleCoreApi.find_customer_by_email_and_rut(quotation.customer.email,quotation.customer.rut)
      if customer and quotation
        customer = customer["data"]
      else
        quotation.customer.replicate_in_core()
        if customer = MieleCoreApi.find_customer_by_email_and_rut(quotation.customer.email,quotation.customer.rut)
          customer = customer["data"]
        else 
          Rails.logger.error "[ERROR CREATE DISPATCH SERVICE IN CORE IN dispatch_group.rb]: Method '#{__method__}', Error en la creacion de cliente #{quotation.customer.email}, en Miele Tickets"
          return false
        end
      end
      
      customer_products_id = dispatch_group.detail_quotation_products.map{|d| d["core_id"]}
      dispatch_guide = dispatch_group.dispatch_guides
      address = "principal"
      customer["additional_addresses"].each do |additional|
        address = additional["id"].to_s if additional["name"] == "Despacho" 
      end

      body_t = {}
      body_t["event_start"] = dispatch_group["dispatch_date"] unless dispatch_group["dispatch_date"].nil?
      body_t["event_end"] = dispatch_group["dispatch_date"] unless dispatch_group["dispatch_date"].nil?
      body_t["quotation_id"] = dispatch_group["quotation_id"].to_s unless dispatch_group["quotation_id"].nil?
      body_t["dispatchgroup_id"] = dispatch_group["id"].to_s unless dispatch_group["id"].nil?
      body_t["payment_state"] = ""
      body_t["service_type"] = "Entregas/Despachos"
      body_t["subcategory"] = dispatch_group["subcategory"].nil? ? "No existen sub-categorías" : dispatch_group["subcategory"] #debería quedar como los primeros cuando se oficialice el parametro
      body_t["requested"] = dispatch_group["requested"].nil? ? "Cliente directo"  : dispatch_group["requested"] #debería quedar como los primeros cuando se oficialice el parametro
      body_t["request_channel"] = dispatch_group["request_channel"].nil? ? "Partners B2B"  : dispatch_group["request_channel"] #debería quedar como los primeros cuando se oficialice el parametro
      body_t["ibs_number"] = quotation["so_code"]
      body_t["address"] = address
      # body_t["products_id"] = products_id.join(",")
      body_t["customer_products_id"] = customer_products_id.join(",")
      body_t["technicians_number"] = dispatch_group["technicians_number"].nil? ? "1" : dispatch_group["technicians_number"] #debería quedar como los primeros cuando se oficialice el parametro
      body_t["technicians_ids"] = dispatch_group["technician_id"] unless dispatch_group["technician_id"].nil?
      body_t["principal_technician"] = dispatch_group["technician_id"] unless dispatch_group["technician_id"].nil?
      body_t["dispatch_guide"] = dispatch_group["dispatch_order"] unless dispatch_group["dispatch_order"].nil?
      body_t["dispatch_guide_url_pdf"] = dispatch_guide.empty? ? "" : dispatch_guide[0].document.url
        
      if dispatch_group.quotation.for_ecommerce?
        body_t["background"] = dispatch_group.notes.find_by(category:"dispatch").observation if dispatch_group.notes.count.positive?
        body_t["b2c_order_number"] = EcommerceSale.find_by(quotation_id: dispatch_group.quotation.id).order_code rescue nil
      else 
        body_t["background"] = dispatch_group.notes.last.observation if dispatch_group.notes.count.positive?
      end
      body_t["dispatch_uuid"] = dispatch_group.dispatch_uuid unless dispatch_group.dispatch_uuid.nil? || dispatch_group.dispatch_uuid.blank?

      response = MieleCoreApi.create_service(customer["id"], body_t)
      quotation.update(installment_service_id: response["id"] )
      quotation.reload
      return true
    rescue Exception => e 
      Rails.logger.error "[ERROR CREATE DISPATCH SERVICE IN CORE IN dispatch_group.rb]: Method '#{__method__}' with error: #{e}"
      return false
    end
  end

  def self.create_installation_service_in_core(dispatch_group)
    begin
      customer_products_id = []
      dispatch_group.detail_quotation_products.map{ |d| customer_products_id.push(d["core_id"]) if d.instalation }
      # dispatch_guide = dispatch_group.dispatch_guides
      if !customer_products_id.empty?
        quotation = dispatch_group.quotation
        address = "principal"
        customer = MieleCoreApi.find_customer_by_email_and_rut(quotation.customer.email,quotation.customer.rut)["data"]
        customer["additional_addresses"].each do |additional|
          address = additional["id"].to_s if additional["name"] == "Instalación"
        end
        
        body_t = {}
          body_t["event_start"] = ""
          body_t["event_end"] = ""
          body_t["quotation_id"] = quotation.id.to_s
          body_t["payment_state"] = ""
          body_t["service_type"] = "Instalación"
          body_t["subcategory"] = "No existen sub-categorías"
          body_t["requested"] = "Cliente directo"
          body_t["request_channel"] = "Partners B2B"
          body_t["ibs_number"] = quotation["so_code"]
          body_t["address"] = address
          # body_t["products_id"] = products_id.join(",")
          body_t["customer_products_id"] = customer_products_id.join(",")
        
        response = MieleCoreApi.create_service(customer["id"], body_t)
        if response
          length_id = response["id"].to_s.length
          installation_sheet = "MTCL#{"0" * (6 - length_id) if (6 - length_id) >= 0 }#{response["id"]}"
          dispatch_group.update(installation_sheet: installation_sheet)
          dispatch_group.reload
          QuotationMailer.installation_service_created(quotation, installation_sheet).deliver_later
          return true
        else 
          return false
        end
      else
        return false
      end
    rescue Exception => e
      Rails.logger.error "[ERROR CREATE INSTALLATION SERVICE IN CORE IN dispatch_group.rb]: Method '#{__method__}' with error: #{e}"
      return false
    end
  end

  def self.update_product_in_core(dispatch_group)
    begin
      quotation = dispatch_group.quotation
      customer = MieleCoreApi.find_customer_by_email_and_rut(quotation.customer.email,quotation.customer.rut)
      if customer and quotation
        customer = customer["data"]
      else 
        return false
      end

      detail_quotation_products = dispatch_group.detail_quotation_products
      detail_quotation_products.each do |p|    
        body_t = {}
        body_t["customer_product_id"] = p["core_id"].to_s
        body_t["quotation_id"] = dispatch_group["quotation_id"].to_s unless dispatch_group["quotation_id"].nil?
        body_t["dispatchgroup_id"] = dispatch_group["id"].to_s unless dispatch_group["id"].nil?  
        response = MieleCoreApi.update_product(customer["id"], body_t)
      end
      return true
    rescue Exception => e 
      Rails.logger.error "[ERROR UPDATE PRODUCT IN CORE IN dispatch_group.rb]: Method '#{__method__}' with error: #{e}"
      return false
    end
  end

  def products_in_dispatch
    return self.product_in_dispatch_groups
  end

  def available_products
    return Product.joins(:dispatch_groups)
                  .where(dispatch_groups: {id: self.id})
                  .where('product_in_dispatch_groups.quantity > 0')
  end

  def self.get_technicians(pais,technician_rol)
    technicians = MieleTicketApi.get_all_technicians(pais)["data"]
    .select{|t| t['activities'].find{|a| a['name'] == technician_rol} }
    .map { |t| [t["user"]["firstname"] +" "+ t["user"]["lastname"] + " - "+ t["enterprise"], t["id"]] } rescue []
  end

  def products_hash
    return products_in_dispatch.map{|item| [item.product, item.quantity]}.to_h
  end

  def check_product_quantities
    pending_products = self.quotation.pending_products_in_dispatch
    return pending_products.select{|k, v| v > 0}
  end

  def partial_project_to_display(current_user)
    'quotations/dispatch/preparation_project'
  end

  def partial_to_display(current_user)
    case self.state.try(:name)
      when 'En preparación'
        if self.quotation.for_project? and current_user.can_manage_project_quotations? and false
          return 'quotations/dispatch/to_project_user'
        else
          return 'quotations/dispatch/in_preparation'
        end
      when 'Despachado'
        return 'quotations/dispatch/dispatched'
      else
        return 'quotations/dispatch/show'
    end
  end

  def can_dispatch?
    return (dispatch_order.present? and 
            dispatch_date.present? and 
            self.observation_by_state.observation.present? and 
            dispatch_guides.any?)
  end

  def to_state(state_name)
    if new_state = QuotationState.find_by(name: state_name)
      self.update(state: new_state)
      
      if self.quotation.pending_detail_products_in_dispatch.length == 0
        self.quotation.check_dispatch_groups_states
      end
    end
    return new_state
  end

  def self.reception_types
    return {
      acepted_reception_by_customer: 'Recepción conforme por cliente',
      acepted_reception_by_courier: 'Recepción conforme por courier',
      partial_reception: 'Recepción parcial',
      pending_reception: 'Pendiente de recepción' 
    }
  end

  def observation_by_state
    case self.state.name
      when 'En preparación'
        return self.notes.dispatch.last
      when 'Despachado'
        return self.notes.reception.last
      when 'Por instalar'
        return self.notes.instalation.last
    end
  end

  def notification_subject(new_state, is_for_miele)
    quotation = self.quotation
    case new_state.name
      when 'Despachado'
        return (is_for_miele ? "[Envío Despachado #{(quotation.is_retail? ? quotation.oc_number : quotation.code)}] Mielecustomers.cl" : "[Confirmación Despacho Envío Miele Chile]")
      when 'Por instalar'
        return (is_for_miele ? "[Envío Entregado #{(quotation.is_retail? ? quotation.oc_number : quotation.code)}] Mielecustomers.cl" : "[Productos Entregados Envío Miele Chile]")
      when 'Instalado'
        return (is_for_miele ? "[Envío Instalado #{(quotation.is_retail? ? quotation.oc_number : quotation.code)}] Mielecustomers.cl" : "[Productos Instalados Envío Miele Chile]")
      when 'Instalación Pendiente'
        return "[Envío con Instalación PENDIENTE #{(quotation.is_retail? ? quotation.oc_number : quotation.code)}] Mielecustomers.cl"
    end
  end

  def to_state_from_reception_type
    return nil unless self.state.name == 'Despachado'

    new_state = 'Por instalar'
    if self.pending_reception?
      new_state = 'En preparación'
      self.notes << [
        DispatchNote.create(category: :dispatch),
        DispatchNote.create(category: :reception)
      ]
    end
    self.to_state(new_state)
  end

  def get_individual_cost
    quotation = self.quotation
    commune = Commune.find(quotation.dispatch_commune_id).region.name
    dispatch_rules = DispatchRule.where(region_name: commune)
    individual_cost = 0
    unless dispatch_rules.empty?
      self.quotation_products_auxes.each do |qp|
        dispatch_rule = dispatch_rules.where("max_amount >= ?",qp["quantity"] ).where("min_amount <= ?",qp["quantity"]).take
        individual_cost += (qp.quantity * (qp.product.product_type == "PAI" ? CartHelper.clp_to_UF(dispatch_rule["pai"]) : qp.product.product_type == "MDA" ? CartHelper.clp_to_UF(dispatch_rule["mda"]) : CartHelper.clp_to_UF(dispatch_rule["sda"]) ))
      end
    end
    individual_cost.round(2)
  end

  def remove_this_product(quotation_product)
    self.quotation_products_auxes.each do |qpa|
      qpa.destroy if qpa.product_id == quotation_product.product_id
    end
  end

  def calculate_cost_for_dispatch_tab
    product_prices = 0
    dispatch_costs = 0
    total_cost = 0
    quotation = self.quotation
    region = Commune.find(quotation.dispatch_commune_id).region.name
    dispatch_rules = DispatchRule.where(region_name: region)
    
    # Adding product prices
    detail_quotation_products = self.detail_quotation_products
    unless detail_quotation_products.empty?
      detail_quotation_products.each do |detail|
        product_prices += detail.quotation_product.price
      end
      # Adding IVA
      product_prices = product_prices * 1.19
    end

    # Adding dispatch costs
    unless detail_quotation_products.empty?
      quantity = detail_quotation_products.count
      dispatch_rule = dispatch_rules.where("max_amount >= ?", quantity).where("min_amount <= ?", quantity).take

      detail_quotation_products.each do |detail|
        product = detail.quotation_product.product
        dispatch_costs += (product.product_type == "PAI" ? CartHelper.clp_to_UF(dispatch_rule["pai"]) : product.product_type == "MDA" ? CartHelper.clp_to_UF(dispatch_rule["mda"]) : CartHelper.clp_to_UF(dispatch_rule["sda"]))
      end

      # Dispatch discount
      if quotation.percentage_discount_dispatch
        dispatch_costs = dispatch_costs - (dispatch_costs * (quotation.percentage_discount_dispatch/100))
      end
    end

    total_cost = product_prices + dispatch_costs
    total_cost.round(2)
  end

  def check_states_and_then_change_state
    quotation = self.quotation
    details = self.detail_quotation_products
    detail_total = details.count

    if details.where(state: 'Entregado').count == detail_total
      self.to_state('Por instalar')
      self.update(reception_type: 0) # "acepted_reception_by_customer"
    elsif details.where(state: 'Instalado').count == detail_total
      self.to_state('Instalado')
    end

    quotation.check_states_and_then_change_state
  end

  private 
    def set_dispatch_notes
      self.notes << [
        DispatchNote.create(category: :dispatch),
        DispatchNote.create(category: :reception),
        DispatchNote.create(category: :instalation)
      ]
    end

    def check_reception_type
      self.quotation.to_state('Despachos e Instalaciones')
    end

    def notify_state_change
      new_state = QuotationState.find(quotation_state_id_change.last)
      if self.quotation.channel != 'Proyectos'
        if !['Ingresada','Entrega Pendiente','Instalación Pendiente'].include?(new_state.name)
          DispatchGroupMailer.change_state(self, new_state).deliver_later
        end
        if Quotation::MAIL_TO_MIELE.include?(new_state.name)
          DispatchGroupMailer.change_state(self, new_state, true).deliver_later
        end
      end
    end

    def add_installation_note
      if installation_confirm_change.last == 'pending'
        self.notes << DispatchNote.create(category: :instalation)
      end
    end
end
