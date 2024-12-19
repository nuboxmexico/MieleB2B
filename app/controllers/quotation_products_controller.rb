class QuotationProductsController < ApplicationController
  before_action :set_quotation_product, only: [ :destroy, :get_updated_to_assign_quantity, :update_quantity, :update_price, :reorganize_dispatch_groups ]
  before_action :set_product, only: :create
  before_action :set_what_refresh, only: [ :update_quantity, :update_price ]

  def destroy
    quotation = @quotation_product.quotation
    dispatch_groups = quotation.dispatch_groups
    dispatch_groups.each { |dispatch_group| dispatch_group.remove_this_product(@quotation_product) }
    config_unit_real_states = quotation.config_unit_real_states
    config_unit_real_states.each { |config_unit| config_unit.remove_this_product(@quotation_product) }
    @quotation_product.destroy
    reorganize_unit_real_states if quotation.products_per_assign_number < 0
    quotation.update_discount_percentage
    quotation.set_products_in_dispatch_group
    respond_to do |format|
      if quotation.save and quotation.update_total
        format.html{ redirect_to quotation, notice: 'Producto eliminado con éxito' }
      else
        format.html{ redirect_to quotation, alert: 'Ocurrió un error al intentar eliminar el producto' }
      end
    end
  end

  def create
    quotation = Quotation.find(params[:quotation_id])
    quotation = quotation.create_new_version unless params[:in_current_version] == "true" 
    if (item = quotation.quotation_products.find_by(sku: quotation_product_params[:sku]))
      item.update(quotation_product_params.merge(product: @product))
    else
      quotation.quotation_products << QuotationProduct.new(
                                        quotation_product_params.merge(product: @product, dispatch: @product.dispatch, instalation: @product.instalation)
                                      )
    end
    quotation.update_discount_percentage
    quotation.set_products_in_dispatch_group
    respond_to do |format|
      if quotation.save and quotation.update_total
        format.html{ redirect_to quotation, notice: 'Producto agregado con éxito' }
      else
        format.html{ redirect_to quotation, alert: 'Ocurrió un problema al agregar el producto' }
      end
    end
  end

  def check_added_product
    quotation = Quotation.find(params[:quotation_id])
    product = quotation.quotation_products.find_by(sku: params[:sku])
    product = Product.find_by(sku: params[:sku]) unless product
    respond_to do |format|
      format.json{ render json: product.to_json }
    end
  end

  def get_updated_to_assign_quantity
    to_assign_quantity = (@quotation_product.quantity_assigned.nil? || @quotation_product.quantity_assigned == 0) ? @quotation_product.quantity : (@quotation_product.quantity - @quotation_product.quantity_assigned)
    render json: { quantity: to_assign_quantity }, status: :ok
  end

  def update_quantity
    reorganize_dispatch_groups if params[:new_quantity].to_i < @quotation_product.quantity && params[:new_quantity].to_i < @quotation_product.dispatch_quantity
    reorganize_config_real_states if params[:new_quantity].to_i < @quotation_product.quantity && params[:new_quantity].to_i < (@quotation_product.quantity_assigned.nil? ? 0 : @quotation_product.quantity_assigned)
    result_update = @quotation_product.update(quantity: params[:new_quantity].to_i)
    reorganize_unit_real_states if @quotation_product.quotation.products_per_assign_number < 0
    if result_update && @quotation_product.quotation.update_total
      @quotation_product.quotation.update_discount_percentage
      respond_to do |format|
        format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: @quotation_product.quotation, quotation_product: @quotation_product, what_refresh: @what_refresh } }
      end
    else
      render json: { status: 'Fail' }, status: :internal_server_error
    end
  end
  
  def update_price
    if @quotation_product.update(price: params[:new_price].to_f) && @quotation_product.quotation.update_total
      @quotation_product.quotation.update_discount_percentage
      respond_to do |format|
        format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: @quotation_product.quotation, quotation_product: @quotation_product, what_refresh: @what_refresh } }
      end
    else
      render json: { status: 'Fail' }, status: :internal_server_error
    end
  end

  private

  def set_what_refresh
    @what_refresh = { installation_box: true,
      all_unit_real_states: true,
      dispatch_groups_container: true,
      dispatch_stats: true,
      all_config_unit_real_states: true,
      glosa: true,
      margin: true
    }
  end

  def set_quotation_product
    @quotation_product = QuotationProduct.find(params[:id])
  end

  def quotation_product_params
    params.require(:quotation_product).permit(:name, :sku, :price, :quantity, :quotation_id)
  end

  def set_product
    @product = Product.find_by(sku: params[:quotation_product][:sku])
    unless @product
      lead_product_params = quotation_product_params.to_h
      lead_product_params['unit_price'] = lead_product_params.delete('price')
      Product.create_to_project_quotations([LeadProduct.new(lead_product_params)])
      
      @product = Product.find_by(sku: lead_product_params['sku'])
    end
  end

  def reorganize_dispatch_groups
    dispatch_groups = @quotation_product.quotation.dispatch_groups
    unless dispatch_groups.empty?
      selected_dispatch_groups = dispatch_groups.select do |dg|
        dg.quotation_products_auxes.each { |qpa| qpa.product_id == @quotation_product.product_id }.any?
      end
      sorted_dispatch_groups = selected_dispatch_groups.sort_by { |dg| dg[:created_at] }.reverse
      quantity_to_remove = @quotation_product.dispatch_quantity - params[:new_quantity].to_i
      sorted_dispatch_groups.each do |sdg|
        quotation_product_aux = sdg.quotation_products_auxes.find_by(product_id: @quotation_product.product_id)
        unless quotation_product_aux.nil?
          if quotation_product_aux.quantity > quantity_to_remove
            delta = quotation_product_aux.quantity - quantity_to_remove
            quotation_product_aux.update(quantity: delta)
            quantity_to_remove = 0
            break
          elsif quotation_product_aux.quantity == quantity_to_remove
            quotation_product_aux.destroy
            quantity_to_remove = 0
            break
          elsif quotation_product_aux.quantity < quantity_to_remove
            quantity_to_remove = quantity_to_remove - quotation_product_aux.quantity
            quotation_product_aux.destroy
          end
        end
      end
      @quotation_product.update(dispatch_quantity: params[:new_quantity].to_i)
    end
  end

  def reorganize_unit_real_states
    quotation = @quotation_product.quotation
    unit_real_states = quotation.unit_real_states.order(id: :desc)
    quantity_to_remove = -quotation.products_per_assign_number
    unless unit_real_states.empty?
      unit_real_states.each do |unit|
        total_unit_quantity = unit.quantity * unit.products_quantity
        if total_unit_quantity < quantity_to_remove
          unit.destroy
          quantity_to_remove -= total_unit_quantity
        elsif total_unit_quantity == quantity_to_remove
          unit.destroy
          quantity_to_remove = 0
          break
        elsif total_unit_quantity > quantity_to_remove
          if quantity_to_remove == unit.products_quantity
            (unit.quantity > 1) ? unit.update(quantity: unit.quantity - 1) : unit.destroy
            quantity_to_remove = 0
            break
          elsif quantity_to_remove < unit.products_quantity
            (unit.quantity > 1) ? unit.update(quantity: unit.quantity - 1) : unit.destroy
            # Commented due to change of requirement
            # new_unit = UnitRealState.create(
            #   quotation_id: quotation.id,
            #   name: unit.name,
            #   quantity: 1,
            #   products_quantity: unit.products_quantity - quantity_to_remove,
            #   is_rm: unit.is_rm
            # )
            # new_unit.calculate_values
            quantity_to_remove = 0
            break
          elsif quantity_to_remove > unit.products_quantity
            division = (total_unit_quantity - quantity_to_remove) / unit.quantity
            remainder = (total_unit_quantity - quantity_to_remove) % unit.quantity
            (division > 0) ? unit.update(quantity: division) : unit.destroy
            # Commented due to change of requirement
            # new_unit = UnitRealState.create(
            #   quotation_id: quotation.id,
            #   name: unit.name,
            #   quantity: 1,
            #   products_quantity: remainder,
            #   is_rm: unit.is_rm
            # )
            # new_unit.calculate_values
            quantity_to_remove = 0
            break
          end
        end
      end
    end
  end

  def reorganize_config_real_states
    config_unit_real_states = @quotation_product.quotation.config_unit_real_states.order(id: 'desc')
    quantity_to_remove = @quotation_product.quantity_assigned - params[:new_quantity].to_i
    config_unit_real_states.each do |config_unit|
      product_in_unit = config_unit.product_in_unit_real_states.find_by(quotation_product_id: @quotation_product.id)
      if product_in_unit
        if product_in_unit.quantity == quantity_to_remove
          product_in_unit.destroy
          break
        elsif product_in_unit.quantity > quantity_to_remove
          delta = product_in_unit.quantity - quantity_to_remove
          product_in_unit.update(quantity: delta)
          break
        elsif product_in_unit.quantity < quantity_to_remove
          quantity_to_remove -= product_in_unit.quantity
          product_in_unit.destroy
        end
      end
    end
    @quotation_product.update(quantity_assigned: params[:new_quantity].to_i)
  end

end