class User < ApplicationRecord
  acts_as_paranoid
  acts_as_token_authenticatable
  has_paper_trail

  belongs_to :role
  belongs_to :sale_channel
  belongs_to :cost_center
  belongs_to :miele_role
  has_one    :cart      , dependent: :destroy
  has_many   :quotations, dependent: :destroy
  has_many   :email_addressees, dependent: :destroy
  has_many   :referred_quotations, class_name: "Quotation", foreign_key: "referred_user_id", dependent: :nullify
  has_many   :dispatch_notes
  
  has_many   :custom_roles, dependent: :destroy
  devise     :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :trackable

  accepts_nested_attributes_for :custom_roles, allow_destroy: true

  validates :name, presence: { message: "no puede estar en vacío"}
  validates :lastname, presence: { message: "no puede estar vacío"}
  validates :second_lastname, presence: { message: "no puede estar vacío"}
  validates :phone, presence: { message: "no puede estar vacío"}
  validates :shop, presence: { message: "no puede estar vacío"}
  validates :workday, presence: { message: "no puede estar vacío"}

  scope :finance_roles, -> {joins(:role).where(roles: {name: ['Finanzas', 'Manager Finanzas']})}

  def generate_api_key
    token = ""
    loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless User.exists?(api_key: token)
    end
    self.update(api_key: token)
  end
  
  def active_for_authentication?
    super && self.active 
  end

  def inactive_message
    "Esta cuenta está desactivada"
  end

  def administrator?
    return self.role.try(:name) == 'Administrador'
  end

  def manager?
    return self.role.try(:name) == 'Manager'
  end

  def seller?
    return self.role.try(:name) == 'Seller'
  end

  def foreign?
    return self.role.try(:name) == 'Consultivo'
  end

  def is_mca?
    return (["Manager","Seller"].include?(self.role.try(:name)) and self.sale_channel.try(:name) == 'MCA')
  end

  def is_project?
    return (["Manager","Seller"].include?(self.role.try(:name)) and self.sale_channel.try(:name) == 'Proyectos')
  end

  def is_retail?
    return (["Manager","Seller"].include?(self.role.try(:name)) and self.sale_channel.try(:name) == 'Retail')
  end

  def is_finance?
    return self.role.try(:name) == 'Finanzas'
  end

  def is_finance_manager?
    return self.role.try(:name) == 'Manager Finanzas'
  end

  def is_dispatch?
    return self.role.try(:name) == 'Despacho'
  end

  def is_instalation?
    return self.role.try(:name) == 'Instalación'
  end

  def is_manager_dispatch?
    return self.role.try(:name) == 'Manager Despacho'
  end

  def is_manager_instalation?
    return self.role.try(:name) == 'Manager Instalación'
  end

  def is_manager_inventory?
    return self.role.try(:name) == 'Manager Inventario'
  end

  def is_project_manager?
    return (self.role.try(:name) == "Manager" and self.sale_channel.try(:name) == 'Proyectos')
  end

  def can_manage_project_quotations?
    return (self.is_project_manager? or self.administrator?)
  end

  def dispatch?
    self.is_dispatch? or self.is_manager_dispatch?
  end

  def instalation?
    return (self.is_instalation? or self.is_manager_instalation?)
  end

  def roles_names
    self.custom_roles.map{|role| "#{role.role.name}#{(role.seller? or role.manager?) ? " #{role.try(:sale_channel).try(:name).to_s}" : ''}"}.join(', ')
  end

  def cant_create
    manager? or 
    manager? or 
    is_manager_dispatch? or 
    is_manager_instalation?
  end

  def cant_see_commissions?
    is_dispatch? || is_manager_dispatch? || is_instalation? || is_manager_instalation?
  end

  def cart_products
    self.cart.present? ? self.cart.cart_items.sum(:quantity) : 0
  end

  def products
    if seller? or manager?
      sale_channel.products
    else
      Product.all
    end
  end

  def self.load_from_excel(file)
    if !(spreadsheet = User.open_spreadsheet(file))
      return false, [-2]
    end
    headers = []
    spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
    headers_required = ['Email', 'Nombre','Apellido Paterno','Apellido Materno','Rol', 'Canal', 'ID Rol', 'Tienda' ,'Centro Costo' ,'Teléfono', 'Jornada', 'Borrar Rol']
    if !headers_required.all? { |e| headers.include?(e) }
      return false, [-1]
    else
      file_errors = []
      i = 0
      spreadsheet.each(email: 'Email', name: 'Nombre', lastname: 'Apellido Paterno', second_lastname: 'Apellido Materno', role: 'Rol', channel: 'Canal', id_role: 'ID Rol', shop: 'Tienda', cost_center: 'Centro Costo', phone: 'Teléfono', work_day: 'Jornada', delete_role: 'Borrar Rol') do |row|
        if i > 0
          begin
            if (role_t = Role.find_by(name: row[:role])) and (cost_center_t = CostCenter.find_by(code: row[:cost_center])) and (miele_role_t = MieleRole.find_by(code: row[:id_role]))
              if (user = User.find_by(email: row[:email].try(:downcase)))
                user.update!(name: row[:name], lastname: row[:lastname], second_lastname: row[:second_lastname], shop: row[:shop], phone: row[:phone], workday: row[:work_day], miele_role: miele_role_t)
              else
                user = User.create!(email: row[:email].try(:downcase), name: row[:name], lastname: row[:lastname], second_lastname: row[:second_lastname], shop: row[:shop], cost_center: cost_center_t, phone: row[:phone], workday: row[:work_day], password: 'mielePartner', miele_role: miele_role_t, role_id: role_t.id, sale_channel: SaleChannel.find_by(name: row[:channel]))
                UserMailer.welcome_mail(user).deliver_later
              end
              if (custom_r = user.custom_roles.find_by(role: role_t, sale_channel: SaleChannel.find_by(name: row[:channel]))) and (row[:delete_role].try(:dowcase) == 'si')
                custom_r.destroy
              elsif !custom_r
                user.custom_roles << CustomRole.create(role: role_t, cost_center: cost_center_t, sale_channel: SaleChannel.find_by(name: row[:channel]))
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
      return true, file_errors
    end
  end

  def self.default_pass
    "mielePartner"
  end

  def list_fullname
    return "#{self.try(:name)} #{self.try(:lastname)}"
  end
  
  def fullname
    return "#{self.try(:name)} #{self.try(:lastname)} #{self.try(:second_lastname)}"
  end

  def role_name
    self.try(:role).try(:name) +' '+self.try(:sale_channel).try(:name).to_s
  end

  def self.finance_roles_emails
    return CustomRole.joins(:user, :role)
                     .includes(:user)
                     .where(roles: {name: ['Finanzas', 'Manager Finanzas']})
                     .map{|custom_role| custom_role.user.email}
  end 

  def have_custom_roles?(role_names)
    return self.custom_roles
               .includes(:role)
               .where(roles: {name: role_names})
               .any?
  end

  private

    def self.open_spreadsheet(file)
      case File.extname(file.original_filename)
      when ".xls" then Roo::Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else return nil
      end
    end
end
