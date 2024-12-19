class ProductsController < ApplicationController
  require 'will_paginate/array'
  before_action :authenticate_user!
  before_action :set_product      , only: [:show]
  before_action :fetch_stock_of_product_to_miele_core, only: [:show]
  before_action :set_families, only: [:index]
  before_action :set_limits, only: [:index]
  before_action :set_comparator, only: [:index]
  before_action :set_product_by_id, only: [:update]
  before_action :set_cart, only: [:show]
  before_action :set_multiple_products, only: [:destroy]
  authorize_resource

  def business_units
    @banners = Banner.where("start_date <= ? and end_date >= ?", Date.today, Date.today)
  end

  def index
    @bstock = false
    if current_user.seller? or current_user.manager?
      @base = current_user.sale_channel
                          .products
                          .joins(:product_families)
                          .where(product_families: {family: @business_unit})
      @sale_channels = SaleChannel.where(id: current_user.sale_channel).pluck(:id)
    else
      @base = @business_unit.products
      @sale_channels = SaleChannel.all.pluck(:id)
    end
    if params[:family] == 'offer'
      if params[:max] and params[:min]
        @products = @base.not_bstock.joins(:product_discount, product_discount: :discount_sale_channels).where("product_discounts.end_date >= ?", Date.today).where(discount_sale_channels: {sale_channel_id: @sale_channels}).where(price: (params[:min].to_i)..(params[:max].to_i)).order(stock: :desc).uniq.paginate(page: params[:page], per_page: 12)
      else
        @products = @base.not_bstock.joins(:product_discount, product_discount: :discount_sale_channels).where("product_discounts.end_date >= ?", Date.today).where(discount_sale_channels: {sale_channel_id: @sale_channels}).order(stock: :desc).uniq.paginate(page: params[:page], per_page: 12)
      end
    elsif params[:family] == 'outlet'
      if params[:max] and params[:min]
        @products = @base.outlet_not_bstock.where(price: (params[:min].to_i)..(params[:max].to_i)).order(stock: :desc).uniq.paginate(page: params[:page], per_page: 12)
      else
        @products = @base.outlet_not_bstock.uniq.paginate(page: params[:page], per_page: 12)
      end
    elsif params[:family] == 'bstock'
      if params[:max] and params[:min]
        @products = @base.bstock.where(price: (params[:min].to_i)..(params[:max].to_i)).order(stock: :desc).uniq.paginate(page: params[:page], per_page: 12)
      else
        @products = @base.bstock.uniq.paginate(page: params[:page], per_page: 12)
      end
      @bstock = true
    elsif params[:family] and !params[:family].empty? and params[:max] and params[:min]
      @products = @base.where(id: Family.find_by(id: params[:family]).products.pluck(:id)).not_bstock.where(price: (params[:min].to_i)..(params[:max].to_i)).order(stock: :desc).uniq.paginate(page: params[:page], per_page: 12)
    elsif params[:family] and !params[:family].empty?
      @products = @base.where(id: Family.find_by(id: params[:family]).products.pluck(:id)).not_bstock.order(stock: :desc).uniq.paginate(page: params[:page], per_page: 12)
    elsif params[:max] and params[:min]
      @products = @base.not_bstock.where(price: (params[:min].to_i)..(params[:max].to_i)).order(stock: :desc).uniq.paginate(page: params[:page], per_page: 12)
    else
      @products = @base.not_bstock.order(stock: :desc).uniq.paginate(page: params[:page], per_page: 12)
    end
    @destroy = !(params[:page] and params[:page].to_i > 1)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    if params[:bstock]
      @bstocks = Product.where(sku: @product.sku).where.not(ean: nil).order('discount DESC')
    end
    respond_to do |format|
      format.html
      format.json{ render json: @product.to_json }
    end
  end

  def bstock
    @products = Product.bstock
                       .joins(product_families: :family)
                       .where('families.depth = 0')
                       .order('families.name DESC, products.discount ASC')
                       .paginate(page: params[:page], per_page: 12)
    @items = Product.bstock
                    .joins(product_families: :family)
                    .where('families.depth = 0')
                    .count
  end

  def destroy
    @products.destroy_all
    respond_to do |format|
      format.html{redirect_to bstocks_path, notice: 'Productos B-Stock eliminados con éxito.'}
    end
  end

  def update
    @product.attributes = product_params
    @updated = @product.changed.first
    @product.save
    respond_to do |format|
      format.js
    end
  end

  def search
    @products = current_user.products.where('lower(sku) LIKE ? OR lower(name) LIKE ?', "%#{params[:search_product].downcase}%", "%#{params[:search_product].downcase}%")
                                     .where('(stock > 0 OR stock_break = TRUE) AND ean IS NULL')
  end

  def template_mandatory
    @filename = "plantilla_mandatorios"
    send_template
  end

  def template_products
    @filename = "plantilla_productos"
    send_template
  end

  def template_discounts
    @filename = "plantilla_descuentos"
    send_template
  end

  def template_stock
    @filename = "plantilla_stock"
    send_template
  end

  def template_comparator
    @filename = "plantilla_comparador"
    send_template
  end

  # Metodo que permite Sincronizar de forma individual un producto con la data que contiene Miele Core
  def synchronize_one_product_with_miele_core 
    message = 'Ocurrio un error con la solicitud del producto a Miele Core'
    errors_report = []
    product_from_core = MieleCoreApi.find_product_by_tnr("#{params[:sku]}")["data"].first

    if product_from_core['platform'] && product_from_core['platform'].downcase.include?('b2b')
      asociated_families = RequestDataMieleCore.find_asociated_families_in_b2b(product_from_core['taxons']) rescue nil  
      b2b_product_records = Product.where(sku:params[:sku]) rescue nil

      if !product_from_core.blank? and !asociated_families.blank? and !b2b_product_records.empty?
        new_data = {
          new_price: product_from_core["product_prices"].find{|pp| pp['country_id'] == 2}['price'].to_i,
          new_stock: product_from_core["product_stocks"].find{|pp| pp['country_id'] == 2}['stock'].to_i,
          new_break_stock: product_from_core["product_stocks"].find{|pp| pp['country_id'] == 2}['break']
        }
        b2b_product_records.each_with_index do |product,i|
          RequestDataMieleCore.update_product_from_core_in_b2b(product_from_core, product, new_data, asociated_families, [], errors_report)
        end

        if errors_report.empty?
          message = "El producto de TNR:#{params[:sku]} se sincronizó con exito"
        end
      end
    end

    respond_to do |format|
      format.html{redirect_to product_path, notice: message}
    end  
  end

  private

  def product_params
    params.require(:product).permit(:id, :specs, :product_functions, :drink_specialty, :basket_design, :wash_program, :dry_program, :maintenance_care, :security, :efficiency_sustain, :accessories)
  end

  def set_product_by_id
    @product = Product.find_by(id: params[:id])
  end

  def set_product
    @product = Product.find_by(sku: params[:sku], ean: nil)
  end

  def set_limits
    @min = Product.minimum(:price)
    @max = Product.maximum(:price)
  end

  def set_families
    @business_unit = Family.find_by(name: params[:business_unit])
    @families = Family.find_by(name: params[:business_unit]).try(:children)
  end

  def set_comparator
    @comparator = Comparator.find_or_create_by(user: current_user)
  end

  def set_cart
    @cart = Cart.find_or_create_by(user: current_user)
  end

  def set_multiple_products
    @products = Product.where(id: params[:id])
  end

  # Metodo que actualiza el stock de un producto con miele core antes de mostrarlo
  def fetch_stock_of_product_to_miele_core
    response = MieleCoreApi.fetch_stock([@product.sku])
    if response 
      if response["#{@product.sku}"]
        @product.update!(stock:response["#{@product.sku}"])
      else 
        @product.update!(stock:0)
      end
    else
      @product.update!(stock:0)
    end
  end
end
