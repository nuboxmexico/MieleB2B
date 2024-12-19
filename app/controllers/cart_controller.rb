class CartController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product  , only: [ :add_product, :add_product_bstock ]
  before_action :set_cart_item, only: [ :minus_product, :plus_product, :remove_product, 
                                       :set_dispatch, :set_instalation, 
                                       :mandatories_by_instalation, :update_item_price ]
  before_action :set_cart     , only: [ :index, :add_product, :minus_product, 
                                       :plus_product, :add_service, :remove_product, 
                                       :empty, :change_percent, :apply_promotion, 
                                       :add_mandatory_to_cart, :add_product_bstock, 
                                       :set_instalation, :apply_discount, :from_quotation,
                                       :update_totals ]
  before_action :update_cart_items_stocks, only: [ :index ]
  before_action :set_quotation, only: :from_quotation
  before_action :reset_dispatch, only: [ :index ]
  authorize_resource

  def clp_to_UF(price_clp)
    unless price_clp
			return 0
		end
		uf = Indicator.where(name: "uf").take
		if uf
			return ((1/ uf["value"]) * price_clp).round(2)
		else
			return 0
		end 
  end

  def index
    @uf = Indicator.where(name: "uf").take
  end

  def add_product
    @product.fetch_stock_of_product_to_miele_core
    check_normal_cart
    @success = false  
    if !@cart.bstock or @product.is_service
      if @product.is_service and @cart.cart_items.find_by(product: @product)
        @cant_add_again = true
      else
        @cart.add_product_to_cart(@product, params[:quantity] ? params[:quantity] : 1, current_user)
        @success = true
      end
    end
    check_home_program unless current_user.is_project?
    Quotation.define_discount(@cart.cart_items, @cart.promotional_code, @cart.apply_discount) if !@cart.bstock
    respond_js
  end

  def add_product_bstock
    check_bstock
    @success = false
    if @cart.bstock
      @bstock = Product.find_by(id: params[:bstock_id])
      @cart.add_bstock(@product, @bstock, current_user)
      check_home_program
      @success = true
    end
    respond_js
  end

  def minus_product
    @success = (@cart_item.minus_product_to_cart ? true : false)
    Quotation.define_discount(@cart.cart_items, @cart.promotional_code, @cart.apply_discount) if (!@cart.bstock and @success)
    @cart.clean if (@cart.cart_items.size == 0 and @success)
    respond_js
  end

  def plus_product
    if current_user.is_project_manager? or (@cart_item.product.stock >= @cart_item.quantity + 1 or @cart_item.product.stock  == 0)
      @success = @cart_item.plus_product_to_cart
    else
      @success = false
    end
    Quotation.define_discount(@cart.cart_items, @cart.promotional_code, @cart.apply_discount) if (!@cart.bstock and @success)
    respond_js
  end

  def remove_product
    @removed_id = params[:id]
    if (ins_t = @cart_item.product_instalation)
      for_delete = @cart.cart_items.where(product: ins_t.products.pluck(:id))
      @products_to_delete = for_delete.pluck(:id)
    end
    if @cart_item.mandatory
      @parent = @cart.cart_items.find_by(order_item: @cart_item.order_item, mandatory: false)
    end
    @is_home_program = (@cart_item.product.sku == 'PEM')
    @cart_item.destroy!
    @cart.reload
    for_delete.destroy_all if for_delete
    check_home_program if !@is_home_program
    Quotation.define_discount(@cart.cart_items, @cart.promotional_code, @cart.apply_discount) if !@cart.bstock
    respond_js
  end

  def empty
    @cart.clean
    quotation = check_quotation_token
    quotation.destroy
    cookies.delete :quotation_request
    respond_js
  end

  def change_percent
    @cart.update(pay_percent: params[:percent])
    respond_js
  end

  def apply_discount
    @cart.toggle!(:apply_discount)
    Quotation.define_discount(@cart.cart_items, @cart.promotional_code, @cart.apply_discount) if !@cart.bstock
    respond_js
  end

  def apply_promotion
    @code_type = params[:type]
    @success, @type = PromotionalCode.validate_code(params[:code], params[:type], @cart)
    Quotation.define_discount(@cart.cart_items, @cart.promotional_code, @cart.apply_discount) if !@cart.bstock
    respond_js
  end

  def add_mandatory_to_cart
    @mandatory_products = Instalation.find_by(id: params[:instalation_id]).products
    @updated_items = []
    @mandatory_products.each do |product|
      if (item = @cart.cart_items.find_by(product: product))
        item.update(quantity: item.quantity + 1)
        @updated_items.push(item)
      else
        @cart.add_product_to_cart(product, 1, current_user)
      end
    end
    @parent = CartItem.find_by(id: params[:parent_id])
    @cart.cart_items.where(product: @mandatory_products).update(order_item: @parent.order_item, linked_mandatory: true)
    @pipe = false
    if @mandatory_products.pluck(:sku).include?('1000') # este es un ducto
      @pipe = true
      @service = Product.find_by(name: 'Pre-visita (IVA incluido)')
      if !@cart.cart_items.find_by(product: @service)
        @added_service = true
        @cart.add_product_to_cart(@service, 1, current_user)
      end
    end
    @mandatory_products = @cart.cart_items.where(product: @mandatory_products)
    @linked = true
    Quotation.define_discount(@cart.cart_items, @cart.promotional_code, @cart.apply_discount) if !@cart.bstock
    @success = true
    respond_js
  end

  def set_dispatch
    @cart_item.update(dispatch: params[:value] == 'true' ? true : false)
    respond_js
  end

  def set_instalation
    @cart_item.update(instalation: params[:value] == 'true' ? true : false)
    check_home_program
    respond_to do |format|
      format.js { render layout: false, content_type: 'text/javascript' }
    end
  end

  def mandatories_by_instalation
    ins = Instalation.find_by(id: params[:instalation_id])
    if @cart_item.product_instalation and (@cart_item.product_instalation.products.size > 0) and (@cart_item.product_instalation != ins) and @cart_item.cart.cart_items.where(product: @cart_item.product_instalation.products).size > 0 
      @success = false
    else
      @cart_item.update(product_instalation: ins)
      @products = ins.products.pluck(:name)
      @success = true
    end
    respond_to do |format|
      if @success 
        format.json{render json: @products}
      else
        format.json {render :json => {previous_value: @cart_item.id}, :status => :internal_server_error }
      end
    end
  end

  def from_quotation
    @cart.reset_with_new_products(@quotation, current_user)
    @cart.reload
    #checkeo cupones
    PromotionalCode.validate_code(@cart.quotation.promotional_code.try(:code), 'product', @cart) if @cart.quotation.promotional_code
    PromotionalCode.validate_code(@cart.quotation.dispatch_code.try(:code), 'dispatch', @cart) if @cart.quotation.dispatch_code
    #checkeo promociones denuevo vigentes
    Quotation.define_discount(@cart.cart_items, @cart.promotional_code, @cart.apply_discount) if !@cart.bstock
    redirect_to cart_path, notice: 'Se han agregado al carro los productos de la cotización y se han ajustado las promociones y stock.'
  end

  def update_totals
    respond_to do |format|
      format.js {render partial: 'cart/update_totals'}
    end
  end

  def update_item_price
    respond_to do |format|
      if @cart_item.update(price: params[:price])
        format.any {render json: {ok: true}, status: :ok}
      else
        format.any {render json: {ok: false}, status: :internal_server_error}
      end
    end
  end

  def calculate_margen
    cart_item_id = params["id"]
    cart_item = CartItem.find(cart_item_id)
    margen_percentage = 0
		if cart_item
			product = Product.find(cart_item["product_id"])
			product_price = Cart.euro_to_UF(product["price_eur"].to_f)
			product_cost = Cart.euro_to_UF(product["cost"].to_f)
      
			if product["price_eur"] && product["cost"]
				margen = cart_item["quantity"].to_i * (cart_item["price"] - product_cost)
				margen_percentage = (margen / (cart_item["quantity"].to_i * cart_item["price"])) * 100
			end
		end

    render json: margen_percentage.round(2), status: 200

	end

  private

    def update_cart_items_stocks
      @cart.cart_items.each do |item|
        unless item.product.sku == 'PEM'
          response = MieleCoreApi.fetch_stock([item.product.sku])
          if response.nil? || response.empty?
            item.destroy
          else
            stock = response[item.product.sku]
            if stock < item.quantity && stock > 0
              item.update(quantity: stock)
            else
              item.update(backorderable: true)
            end  
            #item.destroy if stock <= 0 || stock.nil?
          end
        end
      end
    end

    def reset_dispatch
      @cart.update(installation_value: 0)
      unless @cart.quotation
        @cart.update(dispatch_value: 0)
        @cart.update(dispatch_code: nil)
        @cart.update(promotional_code: nil)
        Quotation.define_discount(@cart.cart_items, @cart.promotional_code, @cart.apply_discount) if !@cart.bstock
      end
    end

    #Metodo que verifica si los cart_items dentro del carrito sufrieron cambios de precio o descuentos despues de ser agregados al carro.
    def check_changes_of_products_in_cart
      @cart.cart_items.each do |cart_item|      
        if current_user.is_project?
          changed_price = clp_to_UF(cart_item.product.price)
          if cart_item.price != changed_price
            cart_item.update(price:changed_price)
          end 
        else
          changed_price = get_price_with_discount(cart_item.product)   
          if cart_item.price != changed_price
            cart_item.update(price:changed_price)
          end 
        end
      end 
    end

    #Metodo que obtiene el precio de un producto con su descuento asociado, si es que es valido
    def get_price_with_discount(product)
      if (product.product_discount) and 
        (product.product_discount.discount > 0) and 
        (product.product_discount.start_date <= Date.today) and 
        (product.product_discount.end_date >= Date.today)
        return (product.price * (1-product.product_discount.discount.to_f/100)).round()
      end
      return product.price
    end

    def set_cart
      @cart = Cart.find_or_create_by(user: current_user)
      check_changes_of_products_in_cart
    end

    def set_product
      @product = Product.find(params[:id])
    end

    def set_cart_item
      @cart_item = CartItem.find(params[:id])
    end

    def set_quotation
      @quotation = Quotation.find_by(id: params[:id])
    end

    def check_bstock
      if @cart.cart_items.empty?
        @cart.update(bstock: true)
      end
    end

    def check_normal_cart
      if @cart.cart_items.empty?
        @cart.update(bstock: false)
      end
    end

    def check_home_program
      @home_program = Product.find_by(sku: 'PEM')
      @item_pem = @cart.cart_items.find_by(product: @home_program)
      if @cart.cart_items.to_install.any? and !@item_pem
        @cart.add_product_to_cart(Product.find_by(sku: 'PEM'), 1, current_user)
        @added_home_program = true
        @cart.reload
      elsif @cart.cart_items.to_install.empty? and @item_pem
        @deleted_id = @item_pem.id
        @cart.cart_items.find_by(product: @home_program).try(:destroy)
        @deleted_home_program = true
        @cart.reload
      end
    end
end
