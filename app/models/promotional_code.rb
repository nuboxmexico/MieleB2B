class PromotionalCode < ApplicationRecord
  has_many :codes_per_channels, dependent: :destroy
  has_many :sale_channels, through: :codes_per_channels
  has_many :carts
  has_many :quotations

  has_many :dispatch_carts, class_name: "Cart", foreign_key: "dispatch_code_id", dependent: :nullify
  has_many :dispatch_quotations, class_name: "Quotation", foreign_key: "dispatch_code_id", dependent: :nullify
  validates :name                   , presence: { message: "no puede estar vacío"}
  validates :code                    , presence: { message: "no puede estar vacío"}
  validates :use_limit                  , presence: { message: "no puede estar vacío"}
  validates :start_date                  , presence: { message: "no puede estar vacío"}
  validates :end_date , presence: { message: "no puede estar vacío"}
  validates :percent, presence: { message: "no puede estar vacío"}

  def self.create_with_sale_channel(params)
  	if code = PromotionalCode.create!(params.except(:sale_channels))
  		params[:sale_channels].each do |channel| 
  			(channel_code = SaleChannel.find_by(id: channel)) ? code.sale_channels << channel_code : false
  		end
  		true
  	else 
  		false
  	end
  end

  def self.validate_code(code_text, type_code, cart)
    if code = PromotionalCode.where(code: code_text).last
      if code.is_for_product == (type_code == 'product' ? true : false)
        if (code.quotations.size < code.use_limit or code.use_limit == -1) 
          if Date.today.between?(code.start_date, code.end_date)
            if type_code == 'product'
              cart.promotional_code_id = code.id
              cart.save!
            else
              cart.update!(dispatch_code: code)
              cart.reload
            end
            return true, 0
          else
            return false, 1
          end
        else 
          return false, 2
        end
      else
        return false, 4
      end
    else
      return false, 3
    end
  end
end
