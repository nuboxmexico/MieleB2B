class DispatchGroupsController < ApplicationController
  before_action :set_dispatch_group, except: [:new, :create, :create_show, :new_for_project, :new_for_project_show, :delete_dispatch_group_project, :delete_dispatch_group_project_show, :delete_aux, :delete_aux_show ]
  before_action :remove_product_params, only: [:update, :installation]
  before_action :check_quantity_in_dispatch_from_params, only: [:update]
  after_action :add_images_to_note, only: :installation
  before_action :set_what_refresh, only: [ :update_dispatch_quantity_show, :delete_aux_show, :delete_dispatch_group_project_show, :update_show, :create_show ]

  @@selected_detail_quotation_products ||= [] # Una forma de Solucionar Un error imposible

  def new
    @technicians_new = DispatchGroup.get_technicians(Rails.application.secrets.country_CL, "Entregas/Despachos")
    @quotation = Quotation.find(params[:quotation_id].to_i)
    @dispatch_group = @quotation.new_dispatch_group
    @dispatch_groups_quantity = @quotation.dispatch_groups.count + 1
    @pending_products_in_dispatch = @quotation.pending_products_in_dispatch
    @@selected_detail_quotation_products = DetailQuotationProduct.string_ids_to_object(params["detail_quotation_products"])
    @selected_detail_quotation_products = @@selected_detail_quotation_products
    respond_to do |format|
      format.js
    end
  end
  
  def new_for_project
    @quotation = Quotation.find(params[:quotation_id].to_i)
    @dispatch_group = @quotation.new_dispatch_group_project
    @dispatch_groups_quantity = @quotation.dispatch_groups.count + 1
    respond_to do |format|
      format.js
    end
  end

  def new_for_project_show 
    @quotation = Quotation.find(params[:quotation_id].to_i)
    @dispatch_group = @quotation.new_dispatch_group_project
    @dispatch_groups_quantity = @quotation.dispatch_groups.count + 1
    respond_to do |format|
      format.js
    end
  end

  def delete_dispatch_group_project
    dispatch_group = DispatchGroup.find(params[:dispatch_group_id])    
    if params["cart_id"].present?
      cart = Cart.find(params["cart_id"])
      dispatch_group.quotation_products_auxes.each do |aux| 
        cart_item = CartItem.where(product_id: aux["product_id"], cart_id: params["cart_id"]).take
        cart_item.update(dispatch_quantity: (cart_item["dispatch_quantity"] - aux["quantity"])) 
      end
    end
    dispatch_group.destroy
  end

  def delete_dispatch_group_project_show
    dispatch_group = DispatchGroup.find(params[:dispatch_group_id])
    quotation = dispatch_group.quotation

    dispatch_group.quotation_products_auxes.each do |aux|
      quotation_product = QuotationProduct.where(quotation_id: quotation.id, product_id: aux.product_id).take
      if quotation_product
        quotation_product.update(dispatch_quantity: ( quotation_product.dispatch_quantity - aux.quantity )) unless quotation_product.dispatch_quantity.nil? && aux.quantity.nil? 
        @dispatch_products = quotation.quotation_products.where(dispatch: true)
      end
    end

    dispatch_group.destroy

    respond_to do |format|
      format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: quotation, what_refresh: @what_refresh } }
    end
  end

  def update_dispatch_quantity
    ids = params["cart_items_id"]
    quantities = params["quantities"]
    ids.each_with_index do |item, index|
      cart_item = CartItem.find(item)
      product = cart_item.product
      if cart_item 
        aux = QuotationProductsAux.where(product_id: cart_item["product_id"], dispatch_group_id: @dispatch_group["id"]).take
        if aux
          aux.update(quantity: (aux["quantity"] + quantities[index.to_i].to_i))
        else
          QuotationProductsAux.create(dispatch_group_id: @dispatch_group["id"], product_id: cart_item["product_id"], quantity: quantities[index.to_i], name: product["name"], sku: product["sku"])
        end                                 
        cart_item.update(dispatch_quantity:  (quantities[index.to_i].to_i + cart_item["dispatch_quantity"]))
      end      
    end
  end

  def update_dispatch_quantity_show
    ids = params["cart_items_id"]
    quantities = params["quantities"]
    ids.each_with_index do |item, index|
      quotation_product = QuotationProduct.find(item)
      product = quotation_product.product
      if quotation_product 
        aux = QuotationProductsAux.where(product_id: quotation_product["product_id"], dispatch_group_id: @dispatch_group["id"]).take
        if aux
          aux.update(quantity: (aux["quantity"] + quantities[index.to_i].to_i))
        else
          QuotationProductsAux.create(dispatch_group_id: @dispatch_group["id"], product_id: quotation_product["product_id"], quantity: quantities[index.to_i], name: product["name"], sku: product["sku"])
        end                                 
        quotation_product.update(dispatch_quantity:  (quantities[index.to_i].to_i + quotation_product["dispatch_quantity"]))
      end      
    end

    respond_to do |format|
      format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: @dispatch_group.quotation, what_refresh: @what_refresh } }
    end
  end

  def delete_aux
    aux = QuotationProductsAux.find(params["aux_id"])
    unless params["cart_id"].nil? 
      cart = Cart.find(params["cart_id"]) 
      cart_item = CartItem.where(cart_id: cart["id"], product_id: aux["product_id"]).take
      if cart_item
        cart_item.update(dispatch_quantity:  (cart_item["dispatch_quantity"] - aux["quantity"]))
        @dispatch_products = cart_item.cart.get_dispatch_products
      end
    end
    aux.destroy
  end

  def delete_aux_show
    aux = QuotationProductsAux.find(params["aux_id"])
    @dispatch_group = aux.dispatch_group
    
    unless params["cart_id"].nil? 
      quotation = Quotation.find(params["cart_id"]) 
      quotation_product = QuotationProduct.where(quotation_id: quotation.id, product_id: aux.product_id).take
      if quotation_product
        quotation_product.update(dispatch_quantity: (quotation_product.dispatch_quantity - aux.quantity))
        @dispatch_products = quotation.quotation_products.where(dispatch: true)
      end
    end

    aux.destroy
    
    respond_to do |format|
      format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: @dispatch_group.quotation, what_refresh: @what_refresh } }
    end
  end

  def destroy
    if current_user.is_project?
      @dispatch_group.destroy
    end
    quotation = @dispatch_group.quotation
    respond_to do |format|
      detail_quotation_products = @dispatch_group.detail_quotation_products
      if detail_quotation_products.update(dispatch_group_id: nil, dispatched: false) and @dispatch_group.state.name == 'En preparación' and @dispatch_group.destroy
        quotation.check_dispatch_groups_states
        format.html {redirect_to request.referer, notice: 'Grupo de envío eliminado con éxito'}
      else
        format.html {redirect_to quotation, alert: 'Ocurrió un problema. Intente nuevamente'}
      end
    end
  end

  def create
    if params[:dispatch_group][:quotation_id].present? and params[:dispatch_group][:dispatch_date].present?
      @dispatch_group = DispatchGroup.create(state: QuotationState.find_by(name: 'En preparación'),
                                            quotation_id: params[:dispatch_group][:quotation_id],
                                              dispatch_date: params[:dispatch_group][:dispatch_date])
      @dispatch_group.notes.dispatch.last.destroy
      if current_user.is_project?
        @dispatch_group.save
        respond_to do |format|
          format.js 
          format.html
        end
        #redirect_back fallback_location: root_path, notice: "Product activated"
        # respond_to do |format|
        #   format.html { redirect_to request.referrer, notice: 'Información de despacho registrada con éxito.' }
        # end
      else
        save_or_update
      end
    else 
      respond_to do |format|
        format.html{ redirect_to @dispatch_group.quotation, notice: 'Ocurrió un problema. Intente nuevamente.'}
      end
    end
  end

  def create_show
    @dispatch_group = DispatchGroup.create(state: QuotationState.find_by(name: 'En preparación'),
                                           quotation_id: params[:dispatch_group][:quotation_id],
                                          dispatch_date: params[:dispatch_group][:dispatch_date])
    @dispatch_group.notes.dispatch.last.destroy
    if @dispatch_group.save
      respond_to do |format|
        format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: @dispatch_group.quotation, what_refresh: @what_refresh } }
      end
    end
  end

  def update
    if current_user.is_project?
      @dispatch_group.update(dispatch_group_params)
      respond_to do |format|
        format.js 
        format.html
     end
      # respond_to do |format|
      #   format.html { redirect_to request.referrer, notice: 'Envío actualizado con éxito.'}
      # end
    else
      save_or_update
    end
  end

  def update_show
    if @dispatch_group.update(dispatch_group_params)
      respond_to do |format|
        format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: @dispatch_group.quotation, what_refresh: @what_refresh } }
      end
    end
  end

  def installation
    if params[:dispatch_group][:installation_confirm] == 'confirm'
      params[:dispatch_group].delete(:notes_attributes)
      new_state = 'Instalado'
    else
      new_state = 'Instalación Pendiente'
    end
    respond_to do |format|
      if @dispatch_group.update(dispatch_group_params) and @dispatch_group.to_state(new_state)
        format.html{ redirect_to @dispatch_group.quotation, notice: 'Envío actualizado con éxito.'}
      else
        format.html{ redirect_to @dispatch_group.quotation, notice: 'Ocurrió un problema. Intente nuevamente.'}
      end
    end
  end

  def change_state
    message = 'ERROR DESCONOCIDO'
    begin
      if !@dispatch_group.blank?
        #########################################################################################################################
        if @dispatch_group.quotation.installment_service_id.blank?
          dispatch_flag_creation = DispatchGroup.create_dispatch_service_in_core(@dispatch_group)
          if @dispatch_group.quotation.installment_service_id.blank? || !dispatch_flag_creation
            message = 'Ocurrió un problema con la creacion del servicio de despacho en Miele Tickets. Intente nuevamente.'
          else  
            if !DispatchGroup.update_product_in_core(@dispatch_group)
              Rails.logger.error "[ERROR change_state IN dispatch_group_controller.rb]: Method 'DispatchGroup.update_product_in_core'"  
            end
          end
        end

        #########################################################################################################################
        customer_required_install_products_id = []
        @dispatch_group.detail_quotation_products.map{ |d| customer_required_install_products_id.push(d["core_id"]) if d.instalation }
        if !customer_required_install_products_id.blank?                                                                                 # Esta validacion implica que la cotizacion no tiene servicio de instalacion, por lo que se la salta.
          install_flag_creation = DispatchGroup.create_installation_service_in_core(@dispatch_group)
          if @dispatch_group.installation_sheet.blank? || !install_flag_creation 
            message = 'Ocurrió un problema con la creacion del servicio de instalacion en Miele Tickets. Intente nuevamente.'
          else
            if !DispatchGroup.update_product_in_core(@dispatch_group)
              Rails.logger.error "[ERROR change_state IN dispatch_group_controller.rb]: Method 'DispatchGroup.update_product_in_core'"  
            end
          end
        end

        #########################################################################################################################
        if (!@dispatch_group.quotation.installment_service_id.blank? and customer_required_install_products_id.blank?) or (!@dispatch_group.quotation.installment_service_id.blank? and !@dispatch_group.installation_sheet.blank?)
          @dispatch_group.to_state(params[:new_state])
          message = 'Envío actualizado con éxito.' 
        end
      else
        message = 'Ocurrió un problema no existe el grupo de Despacho. Intente nuevamente.'
      end
    rescue Exception => e
      Rails.logger.error "[ERROR change_state IN dispatch_group_controller.rb]: Method '#{__method__}' with error: #{e}"  
      message = 'Ocurrió un ERROR. Intente nuevamente.'
    end
    respond_to do |format|
      format.html{ redirect_to @dispatch_group.quotation, notice:message}
    end
  end

  def validate_by_finance
    quotation = @dispatch_group.quotation
    respond_to do |format|
      if @dispatch_group.update(finance_validation: true)
        QuotationMailer.dispatch_validated(quotation, current_user).deliver_later if quotation.for_project?
        QuotationMailer.dispatch_validated_for_customer(quotation).deliver_later if quotation.for_project?
        format.html{ redirect_to @dispatch_group.quotation, notice: 'Validado por Finanzas con éxito.'}
      else
        format.html{ redirect_to @dispatch_group.quotation, notice: 'Ocurrió un problema. Intente nuevamente.'}
      end
    end
  end

  private

  def set_what_refresh
    @what_refresh = { installation_box: false,
      all_unit_real_states: false,
      dispatch_groups_container: true,
      dispatch_stats: true,
      all_config_unit_real_states: false,
      glosa: true
    }
  end

  def set_dispatch_group
    @dispatch_group = DispatchGroup.find(params[:id])
  end

  def dispatch_group_params
    params.require(:dispatch_group).permit(
      :dispatch_order, 
      :technician_id,
      :provider_type,
      :freight_order, 
      :dispatch_date, 
      :observations, 
      :reception_type,
      :installation_date,
      :installation_confirm,
      product_in_dispatch_groups_attributes: [
        :id,
        :quantity,
        :product_id
      ],
      notes_attributes: [
        :id,
        :observation,
        :user_id,
        :category
      ]
    )
  end

  def dispatch_group_freight_order_params
    params.require(:dispatch_group).permit(:freight_order)
  end

  def remove_product_params
    if @dispatch_group.state.name == 'Despachado' and params[:dispatch_group][:reception_type] != 'partial_reception'
      params[:dispatch_group].delete(:product_in_dispatch_groups_attributes)
    end
  end

  def add_images_to_note
    note = @dispatch_group.notes.second_to_last
    if params[:backup_images]
      params[:backup_images].each do |file|
        note.image_notes << ImageNote.create(image: file)
      end
    end
  end

  def check_quantity_in_dispatch_from_params
    if dispatch_group_params[:product_in_dispatch_groups_attributes].present?
      @quantity_in_dispatch = 0
      dispatch_group_params[:product_in_dispatch_groups_attributes].each do |i, item| 
        @quantity_in_dispatch += item[:quantity].to_i
      end
    end
  end

  def save_or_update
    if @quantity_in_dispatch.nil? or @quantity_in_dispatch > 0
      dispatch_guides = params[:dispatch_group][:dispatch_guides]
      states_permit_edit_freight_order = [7,8,9,10,11,12,13,14,19]
      if states_permit_edit_freight_order.include? @dispatch_group.state[:id]
        @dispatch_group.update(dispatch_group_freight_order_params)
      else
        @dispatch_group.update(dispatch_group_params)
      end
      if dispatch_guides
        dispatch_guides.each do |document|
          @dispatch_group.dispatch_guides << DispatchGuide.create(
                                                              document: document, 
                                                              role: current_user.role,
                                                              quotation: @dispatch_group.quotation)
        end      
      end
    end

    return if request.nil?
    respond_to do |format|
      if @dispatch_group.detail_quotation_products.length == 0
        if @@selected_detail_quotation_products.length == 0
          format.html{ 
            redirect_to @dispatch_group.quotation, 
            alert: 'Un envío debe tener al menos un producto.'
          }
        else
          format.html{ 
            redirect_to @dispatch_group.quotation, 
            notice: 'Información de despacho registrada con éxito.'
          }
          @@selected_detail_quotation_products.each do |detail|
            detail.update(dispatch_group_id:  @dispatch_group["id"], dispatched: true)
          end
        end
      elsif @dispatch_group.state.name == 'Despachado' and @dispatch_group.to_state_from_reception_type
        format.html{ 
          redirect_to @dispatch_group.quotation, 
          notice: 'Envío actualizado con éxito.'
        }
      else
        format.html{ 
          redirect_to @dispatch_group.quotation, 
          notice: 'Información de despacho registrada con éxito.'
        }
      end
    end
  end
end