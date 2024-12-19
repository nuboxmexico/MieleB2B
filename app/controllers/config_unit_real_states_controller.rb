class ConfigUnitRealStatesController < ApplicationController
  before_action :set_config_unit_real_state, except: [ :create, :clone_unit ]
  before_action :set_what_refresh, only: [ :create, :update, :destroy, :clone_unit ]

  def create
    ConfigUnitRealState.create(config_unit_real_state_params)
    quotation = Quotation.find(config_unit_real_state_params['quotation_id'].to_i)
    replicate_in_core(quotation)

    respond_to do |format|
      format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: quotation, what_refresh: @what_refresh } }
    end
  end

  def update
    @config_unit_real_state.update(config_unit_real_state_params)
    quotation = Quotation.find(@config_unit_real_state.quotation_id)
    replicate_in_core(quotation)

    respond_to do |format|
      format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: quotation, what_refresh: @what_refresh } }
    end
  end

  def destroy
    quotation = @config_unit_real_state.quotation 
    @config_unit_real_state.destroy
    recount_assigned_quantity(quotation)
    replicate_in_core(quotation)

    respond_to do |format|
      format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: quotation, what_refresh: @what_refresh } }
    end
  end

  def clone_unit
    config_unit_real_state_origin = ConfigUnitRealState.find(clone_unit_params['config_unit_id'].to_i)
    products_in_unit_origin = config_unit_real_state_origin.product_in_unit_real_states
    quotation = config_unit_real_state_origin.quotation

    unit_numbers_arr = []
    quotation.config_unit_real_states.each { |u| unit_numbers_arr << u.config_number }

    clone_unit_params['times_to_clone'].to_i.times do |i|
      random_clone_number = rand(100000..999999)
      while unit_numbers_arr.include?("#{config_unit_real_state_origin.config_number}-C#{random_clone_number}")
        random_clone_number = rand(100000..999999)
      end

      config_unit_real_state_clone = ConfigUnitRealState.create(
        quotation_id: config_unit_real_state_origin.quotation_id,
        config_type: config_unit_real_state_origin.config_type,
        config_number: "#{config_unit_real_state_origin.config_number}-C#{random_clone_number}"
      )

      products_in_unit_origin.each do |prod_in_unit_origin|
        product_in_unit_clone = ProductInUnitRealState.create(
          name: prod_in_unit_origin.name,
          sku: prod_in_unit_origin.sku,
          quantity: prod_in_unit_origin.quantity,
          quotation_product_id: prod_in_unit_origin.quotation_product_id,
          config_unit_real_state_id: config_unit_real_state_clone.id,
        )
      end
    end

    quotation = quotation.reload
    recount_assigned_quantity(quotation)
    replicate_in_core(quotation)

    respond_to do |format|
      format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: quotation, what_refresh: @what_refresh } }
    end
  end

  private

  def set_what_refresh
    @what_refresh = { installation_box: false,
      all_unit_real_states: false,
      dispatch_groups_container: false,
      dispatch_stats: false,
      all_config_unit_real_states: true,
      glosa: false
    }
  end

  def set_config_unit_real_state
    @config_unit_real_state = ConfigUnitRealState.find(params[:id])
  end

  def recount_assigned_quantity(quotation)
    units = quotation.config_unit_real_states
    quotation_products = quotation.quotation_products

    quotation_products.each do |qp|
      counter = 0
      units.each do |unit|
        unit.try(:product_in_unit_real_states).each do |prod_in_unit|
          counter += prod_in_unit.quantity if prod_in_unit.quotation_product_id == qp.id
        end
      end
      qp.update(quantity_assigned: counter)
    end
  end

  def replicate_in_core(quotation)
    ConfigUnitRealState.replicate_in_core(quotation)
  end

  def config_unit_real_state_params
    params.require(:config_unit_real_state).permit(
        :quotation_id,
        :config_type,
        :config_number
    )
  end

  def clone_unit_params
    params.permit(
        :config_unit_id,
        :times_to_clone
    )
  end
end
