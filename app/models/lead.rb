class Lead < ApplicationRecord
  has_many :products, class_name: 'LeadProduct'
  has_many :attachments, class_name: 'LeadAttachment'

  scope :not_in_negotiation, -> {where.not(status: :in_negotiation)}

  accepts_nested_attributes_for :products

  enum currency: [
    :usd,
    :clp,
    :uf
  ]

  enum status: [
    :started,
    :on_track,
    :quoted,
    :canceled,
    :in_negotiation
  ]

  before_save :set_net_price

  def self.currency_options
    return {
      usd: 'USD',
      clp: 'CLP',
      uf: 'UF'
    }
  end

  def self.status_options
    return {
      started: 'Iniciado',
      on_track: 'En seguimiento',
      quoted: 'Cotizado',
      canceled: 'Cancelado',
      in_negotiation: 'En negociación'
    }
  end

  def sorted_products
    return self.products.order(id: :asc)
  end

  def add_attachments(attachments)
    return true unless attachments
    if attachments
      new_attachments = []
      attachments.each do |attachment|
        new_attachments << LeadAttachment.new(file: attachment)
      end
    end
    self.attachments << new_attachments
  end

  def status_name
    return Lead.status_options[self.status.to_sym]
  end

  def products_to_quotation
    product_skus = self.products.map{|product| product.sku}
    official_products = Product.where(sku: product_skus)
    if official_products.count == self.products.count
      return official_products
    else
      project_products = self.products.where.not(sku: official_products.map{|p| p.sku})
      Product.create_to_project_quotations(project_products)
      return Product.where(sku: product_skus)
    end
  end

  def existing_skus
    return Product.where(sku: self.products.map{|lead| lead.sku})
                  .map{|product| [product.sku, true]}
                  .to_h
  end

  private 
    def set_net_price
      self.net_price = self.products.inject(0){|sum, product| sum + (product.total_price)}
    end
end
