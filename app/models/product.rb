class Product < ApplicationRecord
  acts_as_paranoid
  scope :outlet_not_bstock, -> {where('(stock > 0 OR stock_break = TRUE) AND outlet = TRUE AND ean IS NULL')}
  scope :not_bstock, -> {where('(stock > 0 OR stock_break = TRUE) AND ean IS NULL')}
  scope :bstock_count, -> {where.not(ean: nil)}
  scope :bstock, -> {where(bstock: true)}
  
  belongs_to :cost_center
  has_and_belongs_to_many :sale_channels, dependent: :destroy
  has_many :instalations, dependent: :destroy

  has_many :cart_items
  has_many :quotation_products
  has_many :quotation_products_auxes
  has_many :images, class_name: 'ProductImage', foreign_key: 'product_id', dependent: :destroy
  has_many :product_families
  has_many :families, through: :product_families

  has_one :product_discount, dependent: :destroy
  has_many :technical_images, dependent: :destroy

  has_many :product_attributes, dependent: :destroy
  has_many :comparable_attributes, through: :product_attributes

  has_many :comparator_products, dependent: :destroy
  has_many :comparators, through: :comparator_products

  has_many :ecommerce_sales, through: :quotation_products

  has_many :retail_products, dependent: :destroy
  has_many :retails, through: :retail_products

  has_many :product_in_dispatch_groups
  has_many :dispatch_groups, through: :product_in_dispatch_groups
  
  def price_formatted
    number_helper.number_with_delimiter(price.round(0))
  end

  def number_helper
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end

  def display_price(user)
    if (discount_t = self.product_discount) and (discount_t.start_date <= Date.today and discount_t.end_date >= Date.today) and (user.administrator? or user.is_manager_inventory? or discount_t.sale_channels.include?(user.sale_channel))
      return true, (self.price.round(0) - (self.price.round(0) * (discount_t.discount / 100.0))) , discount_t.discount, discount_t.end_date
    else
      return false, self.price.round(0), 0, Date.today
    end
  end

  def get_product_photo(type = nil)
    if self.images.any?
      self.images.first.image.url(:original)
    elsif is_service
      type == 'search' ? ActionController::Base.helpers.asset_path("shopping-cart.svg") : 'shopping-cart.svg'
    else
      type == 'search' ? ActionController::Base.helpers.asset_path("product.png") : 'product.png'
    end 
  end

  def can_supply?
    return (stock > 0 || stock_break)
  end

  def is_service
    self.families.include?(Family.find_by(name: 'Servicios', depth: 0))
  end

  def bstock_price(prod_original)
    (((100 - self.discount.to_i)/100.0) * prod_original.try(:price).to_f)
  end

  def original_product
    Product.find_by(sku: self.sku, ean: nil)
  end

  def check_linked_quotations(quotation_parent = nil)
    self.quotation_products.where("quotation_id is not null AND 
                                   quotation_id != ? AND 
                                   quantity > ? AND 
                                   is_service is false", 
                                   quotation_parent, self.stock)
        .map do |quotation_product| 
      if quotation_product.quotation.get_state == 'Enviada'
        quotation_product.quotation.to_state('Cancelada')
      end
    end
  end

  def self.offer_deadline(ids, sale_channels)
    limit = ProductDiscount.where(product_id: ids)
                           .joins(:sale_channels)
                           .where("product_discounts.end_date BETWEEN ? AND ?", Date.today, (Date.today+30.days))
                           .where(sale_channels: {id: sale_channels})
                           .order(end_date: :asc)
                           .uniq
                           .first
    limit ? [limit.end_date, (limit.end_date - Date.today).to_i] : [(Date.today + 30.days), 30]
  end

  def self.discount_stock(items)
    items.each do |item|
      if !item.product.try(:stock_break)
        item.product.with_lock do
          item.product.stock = (item.product.stock - item.quantity)
          item.product.save
        end
        item.product.check_linked_quotations(item.quotation_id)
      end
    end
  end

  def self.reverse_stock(items)
    items.each do |item|
      if !item.product.try(:stock_break)
        item.product.with_lock do
          item.product.stock = (item.product.stock + item.quantity)
          item.product.save
        end
      end
    end
  end

  def name_and_sku
    return "#{self.sku}-#{self.name}"
  end

  def self.create_to_project_quotations(lead_products)
    products_to_project = lead_products.map do |product| 
      {
        sku: product.sku, 
        name: product.name, 
        price: product.unit_price, 
        only_for_project: true
      }
    end
    Product.create(products_to_project)
  end

	def update_core_id
		response_data = MieleCoreApi.find_product_by_tnr(self.sku)['data']

		if response_data.any?
		  self.update(core_id: response_data.first['id'] )
    end
	end

  def self.bulk_update_core_id
    skus = Product.where(core_id:nil).pluck(:sku).join(",") rescue ""
    puts skus
    response_data = MieleCoreApi.find_product_by_tnr(skus, true)['data'] rescue []
    
    response_data.each do |product|
      p = Product.find_by_sku(product["tnr"])
      p.update(core_id: product['id'] ) if p
    end if response_data.any?
    return true
  end

  # Metodo que actualiza el stock de un producto con miele core antes de mostrarlo
  def fetch_stock_of_product_to_miele_core
    response = MieleCoreApi.fetch_stock([self.sku]) rescue nil
    if response 
      if response["#{self.sku}"]
        self.update!(stock:response["#{self.sku}"])
      else 
        self.update!(stock:0)
      end
    else
      self.update!(stock:0)
    end
  end
end
