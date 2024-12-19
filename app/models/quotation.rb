class Quotation < ApplicationRecord
  MAIL_TO_MIELE = ['Cerrado', 'Despachado','Entregado','Entrega Pendiente','Por instalar','Instalación Pendiente', 'Instalado', 'Por activar', 'Productos activados', 'Despachos e Instalaciones']

  acts_as_paranoid

  belongs_to :dispatch_commune  , class_name: "Commune"
  belongs_to :personal_commune  , class_name: "Commune"
  belongs_to :instalation_commune  , class_name: "Commune"
  belongs_to :billing_commune  , class_name: "Commune"
  belongs_to :quotation_state
  belongs_to :user, -> { with_deleted }
  belongs_to :referred_user, -> { with_deleted }, class_name: "User"
  belongs_to :cost_center, -> { with_deleted }
  belongs_to :miele_role, -> { with_deleted }
  belongs_to :partner_referred, -> { with_deleted }, class_name: "MieleRole"
  belongs_to :partner_selected_commission, -> { with_deleted } , class_name: "MieleRole"
  belongs_to :promotional_code,  class_name: 'PromotionalCode'
  belongs_to :dispatch_code, class_name: 'PromotionalCode'
  belongs_to :sale_channel
  belongs_to :retail
  belongs_to :lead
  belongs_to :next_version, class_name: 'Quotation', foreign_key: :next_version_id
  belongs_to :customer
  belongs_to :builder_company

  has_many :quotation_products, dependent: :destroy
  has_many :products, through: :quotation_products
  has_many :detail_quotation_products, through: :quotation_products
  has_many :payments, dependent: :destroy
  accepts_nested_attributes_for :payments

  has_many :sell_note_documents, dependent: :destroy
  has_many :payment_documents, dependent: :destroy
  has_many :billing_documents, dependent: :destroy
  has_many :dispatch_guides, dependent: :destroy
  has_many :credit_notes, dependent: :destroy
  has_many :backup_documents, dependent: :destroy

  has_one :quotation_document, dependent: :destroy

  has_many :quotation_notes, dependent: :destroy

  has_many :dispatch_groups, dependent: :destroy
  has_many :unit_real_states, dependent: :destroy
  has_many :config_unit_real_states, dependent: :destroy
  has_many :dispatch_instructions_files, dependent: :destroy

  before_save { self.rut.try(:downcase)   }
  before_save { self.email.try(:downcase) }

  after_create :set_code 
  after_create :set_state

  before_update :notify_date_change, if: -> { installation_date_changed? or estimated_dispatch_date_changed? }

  before_destroy :remove_payments

  enum currency: [
    :usd,
    :clp,
    :uf
  ]
  def customer_name
    return "#{self.try(:name).to_s} #{self.try(:lastname).to_s} #{self.try(:second_lastname).to_s}"
  end

  def channel
    return "#{self.try(:sale_channel).try(:name)}"
  end

  def is_retail?
    return (channel == 'Retail')
  end

  def steps
    steps_quotation = [['Cotización Enviada', 1]]
    if self.quotation_products.to_retire.size > 0
      steps_quotation << ['Retirado',2]

    end 
    if self.quotation_products.to_dispatch.size > 0
      steps_quotation << ['Pago Realizado',3]

      steps_quotation << ['Despachado',4]

      steps_quotation << ['Entregado',5]

    end 
    if self.quotation_products.to_install.size > 0
      steps_quotation << ['Instalado', 6]

    end 
    if self.quotation_products.find_by(product: Product.find_by(name: 'Home Program'))
      steps_quotation << ['Home Program', 7]
    end
    return steps_quotation
  end

  def save_products(cart, current_user)

    success = true
    cart.cart_items.each do |product|
      success = false unless 
        self.quotation_products << QuotationProduct.new(
          product:   product.product,
          name:      product.name,
          price:     product.price,
          discount:  product.discount,
          discount_type: product.discount_type,
          discount_percent: product.discount_percent,
          quantity:  product.quantity,
          sku:       product.sku,
          mandatory: product.mandatory,
          dispatch:  product.dispatch,
          is_service: product.is_service,
          instalation: product.instalation,
          is_pai: product.is_pai,
          order_item: product.order_item,
          instalation_id: product.instalation_id,
          dispatch_quantity: product.dispatch_quantity,
          backorderable: product.backorderable
        )
    end
    self.update(expiration_date: Product.offer_deadline(quotation_products.pluck(:product_id), (user.manager? or user.seller?) ? [user.sale_channel.id] : SaleChannel.all.pluck(:id))[0])
    success
  end

  def self.define_discount(items, code, apply_discount)
    # si es servicio o si no califica para centro de beneficios no se incluye en los descuentos
    miele_discount = Quotation.discount_miele(items.where(is_service: false, profit_center: true, is_pai: false))
    section_discount = Quotation.cost_next_section(items, miele_discount[1])

    if section_discount[2] * 100 > miele_discount[0]
      items_t = miele_discount[1]
      miele_discount = [(section_discount[2] * 100).to_i, items_t] 
    end
    
    items.each do |item|
      next if item.frozen?
      options = [{discount_type: nil, discount_percent: 0, discount: 0}]
      options.push({discount_type: 'miele', discount_percent: miele_discount[0], discount: (item.price.to_f * miele_discount[0]/100.0)}) if (miele_discount[1].include?(item) and apply_discount)
      options.push({discount_type: 'section', discount_percent: section_discount[2] * 100, discount: (item.price.to_f * section_discount[2])}) if (section_discount[4].include?(item) and apply_discount)
      options.push({discount_type: 'offer', discount_percent: item.product.product_discount.discount, discount: 0}) if (item.product.product_discount and 
                                                                                                                        (item.product.product_discount.start_date <= Date.today) and 
                                                                                                                        (item.product.product_discount.end_date >= Date.today))
      options.push({discount_type: 'code', discount_percent: code.percent, discount: (item.price.to_f * (code.percent/100.0))}) if code
      selected = options.first
      options.map{ |option| selected = ((selected[:discount_percent] < option[:discount_percent]) ? option : selected )}
      item.update(selected)
    end
  end


  def self.cost_next_section(items, visited_items)
    items_for_section = items.where.not(id: visited_items.pluck(:id)).where(is_pai: false, is_service: false, profit_center: true)
    cost = 0
    items_for_section.map{|item| cost += (item.quantity.to_i * item.price.to_f)}
    missing_cost        = 0
    missing_percentage  = 0
    authorized_discount = 0
    next_discount       = 0

    if    cost > 0 && cost < 9999999
      missing_cost = 9999999 - cost
      next_discount       = 5
    elsif cost >= 10000000 && cost < 19999999
      missing_cost        = 19999999 - cost
      authorized_discount = 0.05
      next_discount       = 10
    elsif cost >= 20000000 && cost < 29999999
      missing_cost        = 29999999 - cost
      authorized_discount = 0.1
      next_discount       = 15
    elsif cost >= 30000000
      authorized_discount = 0.15
      next_discount       = 15
    end
    missing_percentage = (missing_cost * 100) / cost if cost > 0
    return missing_cost, missing_percentage.to_i, authorized_discount, next_discount, items_for_section
  end

  def total_cost(tot=nil)
    unless tot
      total = 0
      quotation_products.availables.each do |product|
        total += (product.quantity * product.price)
      end
      total
    else
      tot
    end
  end

  def total_retail
    return (total_cost + self.try(:dispatch_value).to_i)
  end

  def total_section_discount
    discount = 0
    unless self.for_project?
      quotation_products.where(discount_type: 'section').map{|quotation| discount += (quotation.quantity * quotation.discount)}
    end    
    discount
  end

  def total_miele_discount
    discount = 0
    unless self.for_project?
      quotation_products.where(discount_type: 'miele').map{|quotation| discount += (quotation.quantity * quotation.discount)}
    end
    discount
  end

  def discount_per_code
    discount = 0
    unless self.for_project?
      quotation_products.where(discount_type: 'code').map{|quotation| discount += (quotation.quantity * quotation.discount)}
    end
    discount
  end

  def total_per_pay
    if self.pay_percent == 100
      (self.total_calc).round(2)
    else
      (self.total_calc/2 + self.inmediatly_paid).round(2)
    end
  end

  def inmediatly_paid
    for_pay_now = 0
    self.quotation_products.to_retire.map{|quotation| for_pay_now += ((quotation.price * quotation.quantity) - (quotation.discount * quotation.quantity))}
    return (for_pay_now/2)
  end

  def total_for_commission
    total =
      self
        .quotation_products
        .joins(:product)
        .where("products.product_type= 'SDA' or products.product_type= 'MDA'")
        .sum("quotation_products.quantity * (quotation_products.price - quotation_products.discount)")
    if total > 0
      total +=
        self
          .quotation_products
          .joins(:product)
          .where("products.product_type= 'PAI'")
          .sum("quotation_products.quantity * (quotation_products.price - quotation_products.discount)")
    end
    total
  end

  def total_calc(tot = nil)
    (total_before_code(tot) - discount_per_code - self.discount_code_dispatch).round(2)
  end

  def discount_code_dispatch
    self.dispatch_code ? (self.dispatch_value * (self.dispatch_code.percent.to_f / 100 )) : 0
  end

  def total_before_code(tot = nil)
    delta = self.total_cost(tot)
    if !self.bstock
      delta -= (total_section_discount + total_miele_discount)
    end
    delta += self.dispatch_value if self.dispatch_value #&& self.for_project?
    delta += self.installation_value if self.installation_value #&& self.for_project?
    delta += (delta * 0.19) if self.for_project?
    
    delta
  end

  def self.discount_miele(product_items)
    items_for_discount = product_items.where(product_id: Product.joins(:families).where(families: {name: ["Lavadoras","Secadoras","Planchadoras"]}).pluck(:id).uniq)
    quantities = items_for_discount.sum(:quantity)
    if quantities < 2
      miele_discount = [0, []]
    elsif quantities == 2
      miele_discount = [10, items_for_discount]
    elsif quantities >= 3
      miele_discount = [15, items_for_discount]
    end

    section_discount = Quotation.cost_next_section(product_items, miele_discount[1])
    
    if section_discount[2] * 100 > miele_discount[0]
      items_t = miele_discount[1]
      miele_discount = [(section_discount[2] * 100).to_i, items_t] 
    end

    miele_discount
  end

  def from_ecommerce?
    sale_ecom_id = SaleChannel.find_by_name("E-commerce").try(:id)
    sale_ecom_id && (self.sale_channel_id == sale_ecom_id)
  end

  def discount_from_ecommerce
    discount = 0 
    discount = self.total_per_pay - self.total if self.from_ecommerce?
    return discount 
  end

  def full_dispatch_address
    self.try(:dispatch_address).to_s+' '+self.try(:dispatch_address_number).to_s+' '+self.try(:dispatch_dpto_number).to_s
  end

  def full_instalation_address
    self.try(:instalation_address).to_s+' '+self.try(:instalation_address_number).to_s+' '+self.try(:instalation_dpto_number).to_s
  end

  def full_billing_address
    self.try(:billing_address).to_s+' '+self.try(:billing_address_number).to_s+' '+self.try(:billing_dpto_number).to_s
  end

  def check_commission
    if self.user.is_mca?
      discount = 0
      self.quotation_products.not_for_commissions.map{|quotation| discount += ((quotation.quantity * quotation.price) - (quotation.quantity * quotation.discount))}
      applicable_ammount = total_before_code - self.dispatch_value - self.installation_value - discount
      if applicable_ammount < 9_999_999
        self.mca_commission = 0
      elsif applicable_ammount >= 10_000_000 and applicable_ammount < 19_999_999
        self.mca_commission = applicable_ammount * 0.005
      elsif applicable_ammount >= 20_000_000 and applicable_ammount < 29_999_999
        self.mca_commission = applicable_ammount * 0.01
      elsif applicable_ammount >= 30_000_000
        self.mca_commission = applicable_ammount * 0.015
      end
    end
    self.save!
  end

  def check_partner_commission(customer)
    if (com_t = CommissionParameter.find_by('lower_bound <= ? and upper_bound >= ?', self.total_for_commission, self.total_for_commission))
      if self.preferential_customer and self.try(:partner_referred).try(:classification)
        self.update(partner_commission: (self.total_for_commission * 0.05), partner_selected_commission: self.partner_referred)
      elsif (class_t = self.try(:partner_referred).try(:classification))
        self.update(partner_commission: (self.total_for_commission * com_t.send("level_#{class_t.downcase}"))/100.0, partner_selected_commission: self.partner_referred)
      elsif (class_t = self.user.try(:miele_role).try(:classification))
        self.update(partner_commission: (self.total_for_commission * com_t.send("level_#{class_t.downcase}"))/100.0, partner_selected_commission: self.user.miele_role)
      elsif (class_t = customer.user.try(:miele_role).try(:classification))
        self.update(partner_commission: (self.total_for_commission * com_t.send("level_#{class_t.downcase}"))/100.0, partner_selected_commission: customer.user.miele_role)
      else
        self.update(partner_commission: 0)
      end
    else
      self.update(partner_commission: 0)
    end
  end


  def self.old_dispatch
    is_rm = (Commune.find_by(id: commune_id).try(:region).try(:id) == 13)
    dispatch_price = 0
    items = product_items.apply_dispatch
    mdas = items.mdas
    sdas = items.sdas
    total_mdas = mdas.sum(:quantity)
    total_sdas = sdas.sum(:quantity)
    if items.size > 0
      if items.pais.size == items.size
        if is_rm
          return 5_900
        else
          base = 0
          items.pais.map{|item| base += (item.price * item.quantity)}
          return ((base * 0.05) + 5_900).to_i
        end
      else
        mdas.each do |item|
          if item.instalation
            if total_mdas == 1
              dispatch_price += (44_900 * item.quantity)
              dispatch_price += (!is_rm ? (64_900* item.quantity) : 0)
            elsif total_mdas > 1 and total_mdas <= 5
              dispatch_price += (39_900 * item.quantity)
              dispatch_price += (!is_rm ? (59_900 * item.quantity) : 0)
            else
              dispatch_price += (34_900 * item.quantity)
              dispatch_price += (!is_rm ? (54_900 * item.quantity) : 0)
            end
          else
            dispatch_price += (9_900 * item.quantity)
            if !is_rm
              if total_mdas == 1
                dispatch_price += (24_900 * item.quantity)
              elsif total_mdas > 1 and total_mdas <= 5
                dispatch_price += (21_900 * item.quantity)
              else
                dispatch_price += (18_900 * item.quantity)
              end
            end
          end
        end

        sdas.each do |item|
          if item.instalation
            if total_sdas == 1
              dispatch_price += (44_900 * item.quantity)
            elsif total_sdas > 1 and total_sdas <= 5
              dispatch_price += (39_900 * item.quantity)
            else
              dispatch_price += (34_900 * item.quantity)
            end
          else
            dispatch_price += (5_900 * item.quantity)
            if !is_rm
              if total_sdas == 1
                dispatch_price += (24_900 * item.quantity)
              elsif total_sdas > 1 and total_sdas <= 5
                dispatch_price += (21_900 * item.quantity)
              else
                dispatch_price += (18_900 * item.quantity)
              end
            end
          end
        end
      end
    end
    return dispatch_price
  end

  def self.check_dispatch(commune_id, product_items)
    region = Commune.find_by(id: commune_id).try(:region)
    is_rm = (region.try(:id) == 13)
    dispatch_price = 0
    items = product_items.apply_dispatch
    mdas = items.mdas
    sdas = items.sdas
    pais = items.pais
    
    total_mdas = mdas.sum(:quantity)
    total_sdas = sdas.sum(:quantity)
    total_pais = pais.sum(:quantity)

    mda_dispatch_type = Quotation.mda_dispatch_type_checker(total_mdas)
    mda_dispatch_value = mda_dispatch_type == 0 ? 0 : region[mda_dispatch_type]

    sda_dispatch_type = Quotation.sda_dispatch_type_checker(total_sdas)
    sda_dispatch_value = sda_dispatch_type == 0 ? 0 : region[sda_dispatch_type]
    
    if total_mdas > 0 || total_sdas > 0
      pai_value = 0
    else
      pai_dispatch_type = Quotation.pai_dispatch_type_checker(total_pais)
      pai_value = pai_dispatch_type == 0 ? 0 : region[pai_dispatch_type]
    end

    dispatch_price = (mda_dispatch_value * total_mdas) + (sda_dispatch_value * total_sdas) + pai_value rescue 0
    return dispatch_price
  end

  def self.check_installation(commune_id, product_items)
    items = product_items.to_install
    shipping_region = Commune.find_by(id: commune_id).try(:region)
    is_rm = (shipping_region.try(:id) == 13)
    with_instalation = items.sum(:quantity)                
      case with_instalation
          when 1
            if is_rm 
              return 59_900 * with_instalation
            else
              return (54_900 + 49_900) * with_instalation 
            end
          when 2..5
            if is_rm
              return 49_900 * with_instalation
            else
              return (49_900 + 44_900) * with_instalation
            end
          when 6..Float::INFINITY
            if is_rm
              return 44_900 * with_instalation
            else
              return (44_900 + 39_900) * with_instalation
            end
          else
            return 0
        end                                   
  end


  def self.ensure_dispatch_groups
    Quotation
      .joins(:quotation_state)
      .joins("LEFT JOIN dispatch_groups ON dispatch_groups.quotation_id = quotations.id")
      .where(quotation_states: { name: "En preparación" }, dispatch_groups: { id: nil })
      .each do |quotation|
        controller = DispatchGroupsController.new
        controller.params = ActionController::Parameters.new(
          {
            dispatch_group: {
              quotation_id: quotation.id,
              dispatch_date: quotation.agreed_dispatch_date,
              installation_date: quotation.installation_date,
              product_in_dispatch_groups_attributes: quotation.quotation_products.map{|product| product.slice(:quantity, :product_id)},
              notes_attributes: [
                {
                  observation: "",
                  user_id: quotation.user_id,
                  category: "dispatch"
                }
              ]
            }
          }
        )
        controller.create
      end
  end

  def get_state
    return self.try(:quotation_state).try(:name).to_s
  end

  def to_state(state, reactivate = false)
    #if state != "Por instalar"
      self.quotation_state = QuotationState.find_by(name: state)
      self.save!
      if self.channel != 'Proyectos' and !reactivate and state != 'Despachos e Instalaciones'
        if ((!['Ingresada','Entrega Pendiente','Instalación Pendiente', 'Despachos e Instalaciones'].include?(self.get_state)))
          QuotationMailer.change_state(self).deliver_later 
        end
        if (MAIL_TO_MIELE.include?(self.get_state))
          QuotationMailer.change_state(self, true).deliver_later 
        end
      end
    #end
    
  end

  def get_recipients(is_for_miele)
    in_course = EmailAddressee.where(process:'En curso').joins(:user).pluck(:email)
    instalation = EmailAddressee.where(process:'Instalación').joins(:user).pluck(:email)
    marketing = EmailAddressee.where(process:'Marketing').joins(:user).pluck(:email)
    processing = EmailAddressee.where(process:'En preparación').joins(:user).pluck(:email)
    processing_with_ins = EmailAddressee.where(process:'En preparación con instalación').joins(:user).pluck(:email)
    case get_state
    when 'Enviada'
      return self.user.email
    when 'Cerrado'
      return ( is_for_miele ? in_course.push(self.user.email) : self.email)
    when 'Despachado'
      return (is_for_miele ? self.user.email : self.email)
    when 'Entregado'
      return (is_for_miele ? self.user.email : self.email)
    when 'Por instalar'
      return ( is_for_miele ? instalation.push(self.user.email) : self.email)
    when 'Instalado'
      return (is_for_miele ? self.user.email : self.email)
    when 'Por activar'
      return ( is_for_miele ? marketing.push(self.user.email) : self.email)
    when 'Productos activados'
      return (is_for_miele ? self.user.email : self.email)
    when 'En curso'
      return in_course.push(self.user.email)
    when 'En preparación'
      return  (self.quotation_products.to_install.size > 0 ? processing_with_ins.push(self.user.email) : processing.push(self.user.email))
    when 'Entrega Pendiente'
      return  self.user.email
    when 'Instalación Pendiente'
      return  self.user.email
    else
      return self.email
    end
  end

  def delivery_type
    if quotation_products.to_dispatch.size > 0 and quotation_products.to_retire.size > 0
      return 'dispatch+retirement'
    elsif quotation_products.to_dispatch.size > 0
      return 'dispatch'
    else
      return 'retirement'
    end
  end

  def get_subject(is_for_miele)
    case get_state
    when 'Enviada'
      return "Cotización #{(is_retail? ? oc_number : code)} - #{name} #{lastname}"
    when 'En curso'
      case delivery_type
      when 'dispatch'
        return "Despacho #{(is_retail? ? oc_number : code)} - #{name} #{lastname}"
      when 'dispatch+retirement'
        return "Retiro & Despacho #{(is_retail? ? oc_number : code)} - #{name} #{lastname}"
      end
    when 'Pendiente'
      return "Producto pendiente de pago #{(is_retail? ? oc_number : code)} - #{name} #{lastname}"
    when 'Cerrado'
      return (is_for_miele ? "[Retiro de #{(is_retail? ? oc_number : code)}] Mielecustomers.cl" : "[Productos entregados #{(is_retail? ? oc_number : code)} - #{name} #{lastname}]")
    when 'Vencida'
      return "Vencimiento de cotización #{(is_retail? ? oc_number : code)} - #{name} #{lastname}"
    when 'En preparación'
      return "Despacho #{(is_retail? ? oc_number : code)} - #{name} #{lastname}"
    when 'Cancelada'
      return 'Miele Chile informa que su cotización ha sido CANCELADA'
    when 'Despachado'
      return (is_for_miele ? "[Despachado #{(is_retail? ? oc_number : code)}] Mielecustomers.cl" : "[Confirmación Despacho Miele Chile]")
    when 'Entregado'
      return (is_for_miele ? "[Entregado #{(is_retail? ? oc_number : code)}] Mielecustomers.cl" : "[Productos Entregados Miele Chile]")
    when 'Por instalar'
      return (is_for_miele ? "[Entregado #{(is_retail? ? oc_number : code)}] Mielecustomers.cl" : "[Productos Entregados Miele Chile]")
    when 'Instalado'
      return (is_for_miele ? "[Instalado #{(is_retail? ? oc_number : code)}] Mielecustomers.cl" : "[Productos Instalados Miele Chile]")
    when 'Por activar'
      return (is_for_miele ? "[Productos Instalados correspondientes a #{(is_retail? ? oc_number : code)}] Mielecustomers.cl" : "[Productos Instalados Miele Chile]")
    when 'Productos activados'
      return (is_for_miele ? "[Home Program #{(is_retail? ? oc_number : code)}] Mielecustomers.cl" : "[Disfruta tus Equipos Miele Chile]")
    when 'Entrega Pendiente'
      return "[Despacho PENDIENTE #{(is_retail? ? oc_number : code)}] Mielecustomers.cl"
    when 'Instalación Pendiente'
      return "[Instalación PENDIENTE #{(is_retail? ? oc_number : code)}] Mielecustomers.cl"
    end
  end

  def prepare_payment
    if (payments.completed.sum(:ammount) >= self.total) or !['Enviada','En curso', 'Pendiente'].include?(get_state)
      return false, nil
    else
      if (pay_percent == 100 and payments.completed.size == 0)
        ammount_t = total
      elsif (pay_percent == 100 and payments.completed.size > 0)
        ammount_t = (total - payments.completed.sum(:ammount))
      elsif (pay_percent == 50 and payments.completed.size == 0)
        ammount_t = total_per_pay
      elsif (pay_percent == 50 and payments.completed.sum(:ammount) < total_per_pay)
        ammount_t = (total_per_pay - payments.completed.sum(:ammount))
      elsif (pay_percent == 50 and payments.completed.sum(:ammount) > total_per_pay)
        ammount_t = (total - payments.completed.sum(:ammount))
      else
        ammount_t = (total - total_per_pay)
      end
      payment = Payment.create!(quotation: self, ammount: ammount_t, verified: false, state: 'pending', payment_type: 'webpay')
      return true, payment
    end
  end
  
  def load_activation_files(billing_docs, payment_docs, sell_note_docs, backup_documents, current_user)
    user_type_t = ((current_user.is_finance? or current_user.is_finance_manager?) ? 'finance' : 'seller')

    begin
      if billing_docs
        billing_docs.each do |file|
          self.billing_documents.create!(document: file, user_type: user_type_t)
          self.save!
        end
      end

      if payment_docs
        payment_docs.each do |file|
          self.payment_documents.create!(document: file, user_type: user_type_t)
          self.save!
        end
      end

      if sell_note_docs
        sell_note_docs.each do |file|
          self.sell_note_documents.create!(document: file)
          self.save!
        end
      end

      if backup_documents
        backup_documents.each do |file|
          self.backup_documents.create!(document: file)
          self.save!
        end
      end
    rescue Exception => e
      return 'El tipo de documento cargado es inválido'
    end
  end

  def save_document(pdf)
    document = QuotationDocument.new
    document.document = StringIO.new(pdf)
    document.document_content_type = 'application/pdf'
    document.document_file_name = "Orden de Compra #{self.code}.pdf"
    document.quotation = self
    document.save!
  end

  def can_watch_finance?
    channel != 'Proyectos' or (channel == 'Proyectos' and !["Lead","En Negociación", "Ingresada"].include?(get_state))
  end

  def can_watch_dispatch?
    (!["Enviada", "En curso", "Pendiente","Cerrado", "Vencida", "Ingresada", "Finalizado"].include?(get_state) and (channel != 'Proyectos') and (quotation_products.where(is_service: true).count != quotation_products.count)) or 
    (['Cerrado','Por activar', 'Productos activados', 'En preparación', 'Despachos e Instalaciones', 'Despachado', "Por instalar", "Instalado", "Instalación Pendiente", "Finalizado"].include?(get_state) and (channel == 'Proyectos'))
  end

  def can_watch_instalation?
    ["En preparación", "Despachado", "Despachos e Instalaciones", "Por instalar", "Instalado", "Instalación Pendiente", "Por activar", "Productos activados", "Finalizado"].include?(get_state)
  end

  def can_watch_home_program?
    ["Por activar", "Productos activados"].include?(get_state)
  end

  def post_in_preparation_status?
    ['En preparación', 'Despachado', 'Entregado', 'Por instalar', 'Instalado', 'Por activar', 'Productos activados', 'Finalizado'].include?(get_state)
  end

  def can_configure_dispatch?
    return (self.for_project? and ['En curso', 'En preparación'].include?(self.get_state))
  end

  def can_activate?(activation_states=['Enviada', 'En Negociación', 'En preparación'])
    return activation_states.include?(self.get_state)
  end

  def has_documents?
    return (self.billing_documents.any? or 
            self.payment_documents.any? or 
            self.sell_note_documents.any? or 
            self.backup_documents.any?)
  end

  def pending_detail_products_in_dispatch
    detail_quotation_products = []
    self.quotation_products.each do |qp|
      qp.detail_quotation_products.each do |detail|
        unless detail["dispatched"]
          detail_quotation_products.push(detail)
        end
      end
    end
    return detail_quotation_products
  end

  def pending_to_install_detail_products
    detail_quotation_products = []
    self.quotation_products.each do |qp|
      qp.detail_quotation_products.each do |detail|
        if detail["dispatched"] 
          if detail["instalation"] || detail["home_program"]
            detail_quotation_products.push(detail)
          end
        end
      end
    end
    return detail_quotation_products
  end

  def all_detail_products_in_dispatch
    detail_quotation_products = []
    self.quotation_products.each do |qp|
      qp.detail_quotation_products.each do |detail|
        detail_quotation_products.push(detail)
      end
    end
    return detail_quotation_products
  end

  def pending_products_in_dispatch
    quotation_products_hash = self.quotation_products
                                  .order(product_id: :asc)
                                  .map{|item| [item.product, item.quantity]}
                                  .to_h

    self.dispatch_groups.each do |dispatch|
      quotation_products_hash.merge!(dispatch.products_hash) do |key, old_value, new_value|
        old_value - new_value
      end
    end
    return quotation_products_hash
  end

  def set_dispatch_group
    new_dispatch_group = DispatchGroup.create(dispatch_date: self.estimated_dispatch_date,
                                              state: QuotationState.find_by(name: 'En preparación'))
    self.dispatch_groups << new_dispatch_group
    return new_dispatch_group
  end

  def check_dispatch_groups_states
    states = self.dispatch_groups
                 .joins(:state)
                 .group('quotation_states.name')
                 .count
    if states.keys.size == 1
      new_state = states.keys.first
      if new_state == 'Instalado' and self.activation_confirm
        new_state = 'Por activar'
      end
    else
      new_state = 'Despachos e Instalaciones'
    end
    self.to_state(new_state) if new_state != self.get_state
  end

  def set_products_from_lead(lead)
    lead.products_to_quotation.each do |product|
      lead_product = lead.products.find_by(sku: product.sku)
      self.quotation_products << QuotationProduct.new(
        product:   product,
        name:      product.name,
        price:     lead_product.unit_price,
        quantity:  lead_product.quantity,
        sku:       product.sku
      )
    end
    self.save
  end

  def update_total
    self.update(total: self.total_calc.round(2))
  end

  def create_new_version(with_products = true)
    new_version = self.dup
    if with_products
      new_version.quotation_products << self.quotation_products.map { |item| item.dup }      
    end
    new_version.dispatch_groups << self.dispatch_groups.map { |item| item.dup }
    new_version.unit_real_states << self.unit_real_states.map { |item| item.dup }
    # Agregar config de unidades inmobiliarias a la nueva version
    new_version.config_unit_real_states << self.config_unit_real_states.map { |item| item.dup }
    new_version.save
    if self.expiration_date
      days_to_expire = (self.expiration_date - self.created_at.to_date).to_i
      new_expiration_date = days_to_expire.days.from_now
    end
    new_version.update(quotation_state: self.quotation_state, 
                       next_version_id: nil, 
                       code: self.code,
                       expiration_date: new_expiration_date)
    self.update(next_version_id: new_version.id)
    return new_version
  end

  def set_products_in_dispatch_group
    dispatch_group = self.dispatch_groups.first
    if dispatch_group
      products_in_dispatch = self.quotation_products.map do |item| 
        ProductInDispatchGroup.create(product: item.product, quantity: item.quantity) 
      end
      dispatch_group.products_in_dispatch << products_in_dispatch
    end
  end

  def last_version
    last_version = self
    while last_version.next_version
      last_version = last_version.next_version
    end
    return last_version
  end

  def all_versions
    versions = []
    versions << self

    previous = Quotation.find_by(next_version: self)
    while previous
      versions << previous
      previous = Quotation.find_by(next_version: previous)
    end


    versions.reverse!

    next_version = self.next_version
    while next_version
      versions << next_version
      next_version = next_version.next_version
    end

    if versions.size > 1
      return versions.reverse
    else
      return versions
    end
  end

  def pending_amount
    return self.total - self.payments.completed.sum(:ammount)
  end

  def all_completed_payments_are_of_same_type?(payment_type)
    completed_payments = self.payments.completed
    return completed_payments.where(payment_type: payment_type).count == completed_payments.count
  end

  def for_project?
    return self.channel == 'Proyectos'
  end

  def for_ecommerce?
    return self.channel == 'E-commerce'
  end

  def to_pdf(debug_mode = false)
    if self.for_project?
      name = "Cotización_proyecto_#{self.code}"
      template = 'quotations/for_project.pdf.erb'
      specific_options = {
        margin: { 
          top:    0,
          bottom: 0,
          left:   0,   
          right:  0 
        },
        page_width: '29.08cm', 
        page_height: '16.45cm',
        disposition: (debug_mode ? 'inline' : 'attachment')
      }
    else
      name = "documento_#{self.id}"
      template = 'quotations/new_quotation.pdf.erb'
      specific_options = {
        margin: { 
          top:    25,
          bottom: 25,
          left:   20,   
          right:  20 
        },
        header: {
          html: {
           template: 'layouts/_header_pdf.html.erb'
          }
        },
        page_size:    'Letter',
        disposition: 'inline'
      }
    end
    return {
      pdf:          name,
      template:     template, 
      layout:       'document_in_pdf.html',
      title:        name,
      locals:       { quotation: self },
    }.merge(specific_options)
  end

  def new_dispatch_group
    dispatch_group = DispatchGroup.new(dispatch_date: self.estimated_dispatch_date,
                                       state: QuotationState.find_by(name: 'En preparación'),
                                       quotation: self)
    dispatch_group.notes << DispatchNote.new(category: :dispatch)
    products_to_dispatch = self.pending_products_in_dispatch.map do |product, quantity|
      ProductInDispatchGroup.new(product: product, 
                                    quantity: quantity) 
    end
    dispatch_group.products_in_dispatch << products_to_dispatch
    return dispatch_group
  end

  def new_dispatch_group_project
    dispatch_group = DispatchGroup.new(state: QuotationState.find_by(name: 'En preparación'),
                                       quotation: self)
  end

  def new_unit_real_state_project
    unit_real_state = UnitRealState.new(quotation: self)
  end

  def save_dispatch_instructions_files(instructions_files)
    files = instructions_files.map do |instructions_file|
      DispatchInstructionsFile.new(file: instructions_file)
    end
    self.dispatch_instructions_files << files
    self.save
  end

  def set_code
    unless self.user.is_retail?
      new_code = "#{self.try(:cost_center).try(:code)}-#{self.user.try(:miele_role).try(:code)}-#{self.try(:id)}-"
      if self.channel == 'Proyectos'
        new_code += self.try(:project_name).try(:gsub, ' ', '_').to_s
      else
        new_code += self.try(:lastname).try(:gsub, ' ', '').to_s
      end
      self.update(code: new_code)
    end
  end

  def replicate_in_core(quotation)
    return false unless self.customer.replicate_in_core(quotation["observations"]) || !self.customer.core_id.nil?

    not_found_id_product = []
    flag_home_program = home_program_exist?(self.quotation_products)
    products_core_ids = self.quotation_products.map do |qp|
      need_home_program = qp['instalation'] && flag_home_program
      if qp.product.core_id.nil?
        not_found_id_product << qp.product.id
        next 
      end
      Array.new(qp.quantity){ |i| [ qp.product.core_id.to_s, qp["dispatch"]? "Por despachar": "Retirado", qp["dispatch"], qp["instalation"], need_home_program, qp.product.ean ] }
    end.compact.join(",")

    if (replicated_items = self.customer.replicate_products_in_core_id(products_core_ids, self.id, self.code))
      replicated_items.each do |replicated_item|
        item = self.quotation_products.joins(:product)
                                      .find_by(products: {core_id: replicated_item['product_id']})
        if item
          item.update(core_id: replicated_item['id'])
          unless item.product.is_service
            DetailQuotationProduct.create(name: item["name"], state: replicated_item["status"], tnr: item["sku"], quotation_product_id: item["id"] , core_id: item["core_id"], serial_id: replicated_item["b2b_ean"], dispatch: item["core_id"], instalation: item["instalation"], home_program: item["instalation"], admission_date: Date.current)
          end
        end
      end
    end

    create_home_program_service_in_core unless self.for_project?
    ConfigUnitRealState.replicate_in_core(quotation) if self.for_project?

    return true
  end

  def create_home_program_service_in_core
    home_program = self.quotation_products.find_by(sku: 'PEM')
    if home_program
      customer_products_id = []
      self.quotation_products.each do |qp|
        qp.detail_quotation_products.each do |d|
          customer_products_id << d.core_id
        end
      end

      address = "principal"
      customer = MieleCoreApi.find_customer_by_email(self.customer.email)["data"]
      customer["additional_addresses"].each do |additional|
        address = additional["id"].to_s if additional["name"] == "Instalación"
      end

      body_t = {}
      body_t["service_type"] = "Home Program"
      body_t["total_amount"] = home_program.price.to_i.to_s
      body_t["payment_state"] = "paid"
      body_t["status"] = "paid"
      body_t["customer_id"] = customer["id"].to_s
      body_t["quotation_id"] = self.id.to_s
      body_t["subcategory"] = "No existen sub-categorías"
      body_t["requested"] = "Cliente directo"
      body_t["request_channel"] = "Partners B2B"
      body_t["ibs_number"] = self.so_code
      body_t["address"] = address
      body_t["customer_products_id"] = customer_products_id.join(",")

      response = MieleCoreApi.create_service(customer["id"], body_t)
      # Guardar Folio, Enviar Email?
    end
  end

  def webpay_object_data
    payment = self.payments.find_by(verified: false)
    return {
      buy_order: payment.miele_tx_code,
      session_id: rand(1111111..9999999).to_s,
      amount: payment.ammount.to_i,
    }
  end

  def self.mda_dispatch_type_checker(mda_products)
    case mda_products
      when 1
        return "mda_a"                                 
      when 2..5
        return "mda_b"                            
      when 6..Float::INFINITY
        return "mda_c"
      else
        return 0
    end
  end
  
  def self.sda_dispatch_type_checker(sda_products)
    if sda_products == 0
      return 0
    else
      case sda_products
        when 1
        return "sda_a"
        when 2..5
          return "sda_b"
        when 6..Float::INFINITY
          return "sda_c"
      end
    end                   
  end
  
  def self.pai_dispatch_type_checker(pai_items)
    if pai_items > 0
      return "pai_a"
    else
      return 0
    end
  end

  def self.create_cookie(cookies, current_user)
    unless cookies[:quotation_request]
      cookies.permanent.signed[:quotation_request] = Quotation.generate_comp_token
  	end

		unless (quotation_request = Quotation.find_by(guest_token: cookies[:quotation_request]))
			quotation_request = Quotation.new
			quotation_request.guest_token = cookies[:quotation_request]
		end

    if current_user
      quotation_request.user_id = current_user.id
    end

    quotation_request.save
  end

  def total_product
    total_t = 0
    self.quotation_products.each do |product|
      price = ((product.price rescue product.product.price) * product.quantity)
      total_t = total_t + price
    end
    total_t
  end
  
  def total_discount_product
    total = 0
    self.quotation_products.each do |product|
      if product.price != product.product.price
          discount = product.product.discount.nil? ? 0 : (product.product.price.round(0) * (product.product.discount / 100.0) * product.quantity)
          total = total + discount
      end
    end
    total
  end

  def self.generate_comp_token(model_class = Quotation)
    loop do
      token = "#{Quotation.random_token}#{Quotation.unique_ending}"
      break token unless model_class.exists?(guest_token: token)
    end
  end

  def self.random_token
    SecureRandom.urlsafe_base64(nil, false)
  end

  def self.unique_ending
    (Time.now.to_f * 1000).to_i
  end

  def total_discount_product
    total = 0
    self.quotation_products.each do |product|
      if product.price != product.product.price
          discount = product.product.discount.nil? ? 0 : (product.product.price.round(0) * (product.product.discount / 100.0) * product.quantity)
          total = total + discount
      end
    end
    total
  end



  def get_dispatch_cost(commune)
    dispatch_rules = DispatchRule.where(region_name: commune)
    dispatch_group_count = 0
    dispatch_cost = 0
    unless dispatch_rules.empty?
      dispatch_groups = self.dispatch_groups
      dispatch_group_count = dispatch_groups.count
      dispatch_groups.each do |dispatch_group|
        dispatch_group.quotation_products_auxes.each do |qp|
          dispatch_rule = dispatch_rules.where("max_amount >= ?", qp["quantity"] ).where("min_amount <= ?", qp["quantity"]).take
          dispatch_cost = dispatch_cost + (qp.quantity * (qp.product.product_type == "PAI" ? CartHelper.clp_to_UF(dispatch_rule["pai"]) : qp.product.product_type == "MDA" ? CartHelper.clp_to_UF(dispatch_rule["mda"]) : CartHelper.clp_to_UF(dispatch_rule["sda"]) ))
        end
      end
    end
    percentage_discount_dispatch = self.percentage_discount_dispatch
    if percentage_discount_dispatch
      dispatch_cost = dispatch_cost * (1 - (percentage_discount_dispatch/100) )
    end
    return [dispatch_cost.round(2), percentage_discount_dispatch, dispatch_group_count] 
  end

  def calculate_discount_percentage(cart)
    list_prices = 0
    proposed_prices = 0
    cart.cart_items.each do |item|
      proposed_prices = proposed_prices + (item.quantity * item.price)
      list_prices = list_prices + (item.quantity * CartHelper.euro_to_UF(item.product.price_eur))
    end
    discount_percent = list_prices != 0 ? ((list_prices - proposed_prices)*100 / list_prices).round(2) : 0
    discount_percent = discount_percent >= 0 ? discount_percent : 0
  end

  def update_discount_percentage
    list_prices = 0
    proposed_prices = 0
    self.quotation_products.each do |item|
      proposed_prices = proposed_prices + (item.quantity * item.price)
      list_prices = list_prices + (item.quantity * CartHelper.euro_to_UF(item.product.price_eur))
    end
    discount_percent = list_prices != 0 ? ((list_prices - proposed_prices)*100 / list_prices).round(2) : 0
    discount_percent = discount_percent >= 0 ? discount_percent : 0
    self.update(percentage_discount_dispatch: discount_percent)
  end

  def margen_cost
    sub_total = self.total_cost
    # price_eur_total = 0
    # self.quotation_products.each { |quotation_product| price_eur_total = quotation_product.quantity * Cart.euro_to_UF(quotation_product.product.price_eur) if quotation_product.product.cost && quotation_product.product.price_eur }
    margen = 0
    quotation_products.each do |qp|
      margen = margen + calculate_margen(qp)
    end
    total_margen_percentage = sub_total > 0 ? (margen / sub_total) * 100 : 0
    total_margen_percentage.round(2)
  end

  def calculate_margen(quotation_product)
    if quotation_product
      margen = 0
			product = Product.find(quotation_product.product_id)
			product_price = Cart.euro_to_UF(product.price_eur.to_f)
			product_cost = Cart.euro_to_UF(product.cost.to_f)
			if product.price_eur && product.cost
				margen = quotation_product.quantity.to_i * (quotation_product.price - product_cost)
			end
		end
    margen.round(2)
  end

  def calculate_margen_percent(quotation_product)
		margen_percentage = 0
		if quotation_product
			product = Product.find(quotation_product.product_id)
			product_price = Cart.euro_to_UF(product.price_eur.to_f)
			product_cost = Cart.euro_to_UF(product.cost.to_f)
			if product.price_eur && product.cost
				margen = quotation_product.quantity.to_i * (quotation_product.price - product_cost)
				margen_percentage = (margen / (quotation_product.quantity.to_i * quotation_product.price)) * 100
			end
		end
		margen_percentage.round(2)
  end

  def products_dispatch_number
    number = 0
    if self.quotation_products.present?
      self.quotation_products.each do |item|
				number += item.quantity.to_i if item.dispatch
			end
    end
    number
  end

  def products_dispatch_per_assign_number
    number = self.products_dispatch_number
    if self.dispatch_groups.present?
      self.dispatch_groups.each do |dg|
        dg.quotation_products_auxes.each do |qpa|
          number -= qpa.quantity.to_i unless qpa.quantity.nil?
        end
      end
    end
    number
  end

  def products_instalation_number
    number = 0
    if self.quotation_products.present?
      self.quotation_products.each do |item|
        number += item.quantity.to_i if item.instalation
      end
    end
    number
  end

  def products_per_assign_number
    number = self.products_instalation_number
    if self.unit_real_states.present?
      self.unit_real_states.each do |item|
        number -= item.quantity.to_i * item.products_quantity.to_i
      end
    end
    number
  end

  def project_installation_values
    values = ProjectInstallationValue.all
		values_aux = []
    if self.for_project?
			values.each do |valor|
				values_aux.push({
					min_amount: valor["min_amount"],
					max_amount: valor["max_amount"],
					cost_RM: CartHelper.clp_to_UF(valor["cost_RM"]),
					cost_additional_region:  CartHelper.clp_to_UF(valor["cost_additional_region"])
				})
			end    
    end
    values = values_aux
    values
  end
	
  def project_installation_discounts
    discounts = ProjectInstallationDiscount.all
		discounts_aux = []
    if self.for_project?
      discounts.each do |valor|
        discounts_aux.push({
          min_amount: CartHelper.clp_to_UF(valor["min_amount"]),
          max_amount: CartHelper.clp_to_UF(valor["max_amount"]),
          discount_percentage: valor["discount_percentage"]
        })
      end
    end
    discounts = discounts_aux
    discounts
  end

  def payment_type_options
    payment_type_options =[["Pago en efectivo","efectivo"],["Pago con Transferencia", "transferencia"],["Pago Mixto", "mixto"],["Pago Trasbank Tienda", "transbank tienda"],["Pago Webpay (Link)", "webpay link"], ['Saldo a favor', 'saldo a favor']]
	  payment_type_options.push(*[["Cheque","cheque"],["Depósito directo","deposito directo"]]) if self.for_project?
    payment_type_options
  end


  def installation_sheets
    sheets_arr = []
    dispatch_groups = self.dispatch_groups
    dispatch_groups.each { |dg| sheets_arr << dg.installation_sheet unless dg.installation_sheet.nil? }
    sheets_arr
  end

  def check_states_and_then_change_state
    dispatch_groups = self.dispatch_groups
    dispatch_total = dispatch_groups.count

    dispatched = dispatch_groups.where(state: 7).count
    for_install = dispatch_groups.where(state: 9).count
    installed = dispatch_groups.where(state: 11).count

    complete = self.detail_quotation_products.where(dispatch_group: nil).where.not(tnr: 'PEM').count == 0

    if dispatched == dispatch_total
      self.to_state('Despachado')
    elsif for_install == dispatch_total
      self.to_state('Por instalar')
    elsif installed == dispatch_total && complete
      self.to_state('Finalizado')
    else
      self.to_state('Despachos e Instalaciones')
    end
  end

  private

  def home_program_exist?(quotation_products)
    product_home_program = Product.find_by(sku: "PEM")
    return false if product_home_program.blank?

    quotation_products.each do |qp|
      next unless qp.product_id == product_home_program.id

      return true
    end
    false
  end

  def set_state
    if (user.is_retail? or user.is_project?)
      to_state('En Negociación')
    else
      to_state("Enviada")
    end
  end

  def notify_date_change
    if installation_date_changed? 
      changed_date = 'fecha de instalación'
      recipients = EmailAddressee.where(process:'Instalación').joins(:user).pluck(:email)
    elsif estimated_dispatch_date_changed?
      changed_date = 'fecha de despacho'
      recipients = EmailAddressee.where(process:'Despacho').joins(:user).pluck(:email)
    end
    QuotationMailer.change_estimated_date(self, changed_date, recipients).deliver_later
  end

  def remove_payments
    self.payments.destroy_all
  end
end