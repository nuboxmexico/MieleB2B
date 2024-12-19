class UnitRealStatesController < ApplicationController
  before_action :set_unit_real_state, except: [:new, :create, :new_show, :new_config_show, :create_show]
  before_action :set_what_refresh, only: [ :create_show, :update_show, :destroy_show ]

  def new
    @quotation = check_quotation_token
    @unit_real_state_project = @quotation.new_unit_real_state_project
    respond_to do |format|
      format.js
    end
  end

  def new_show
    @quotation = Quotation.find(params["quotation_id"])
    @unit_real_state_project = @quotation.new_unit_real_state_project
    respond_to do |format|
      format.js
    end
  end

  def new_config_show
    @quotation = Quotation.find(params["quotation_id"])
    @unit_real_state_project = @quotation.new_unit_real_state_project
    respond_to do |format|
      format.js
    end
  end

  def create
    if params["unit_real_state"]["is_rm"] == "show"
      @quotation = Quotation.find(params["unit_real_state"]["quotation_id"])
      is_rm = @quotation.dispatch_commune.region.name = "Región Metropolitana" ? true : false
    else
      is_rm = params["unit_real_state"]["is_rm"]
      @quotation = check_quotation_token
    end
    costs = get_cost_rm_and_region(params["unit_real_state"]["products_quantity"].to_i)
    values = {}
    
    if is_rm
      values[:unit_value] = (costs[0] * params["unit_real_state"]["products_quantity"].to_i).round(2)
      values[:total_value] = (costs[0] * params["unit_real_state"]["products_quantity"].to_i * params["unit_real_state"]["quantity"].to_i).round(2)
    else
      values[:unit_value] = ((costs[0] + costs[1]) * params["unit_real_state"]["products_quantity"].to_i).round(2)
      values[:total_value] = ((costs[0] + costs[1]) * params["unit_real_state"]["products_quantity"].to_i * params["unit_real_state"]["quantity"].to_i).round(2)
    end
    @unit_real_state_project = UnitRealState.create(unit_real_state_params.merge(values))
    @counter = @quotation.unit_real_states.length

    render json: @quotation.unit_real_states.to_json
  end

  def create_show
    @quotation = Quotation.find(params["unit_real_state"]["quotation_id"])
    if params["unit_real_state"]["is_rm"] == "show"
      is_rm = @quotation.dispatch_commune.region.name = "Región Metropolitana" ? true : false
    else
      is_rm = params["unit_real_state"]["is_rm"]
      @quotation = check_quotation_token
    end
    costs = get_cost_rm_and_region(params["unit_real_state"]["products_quantity"].to_i)
    values = {}
   
    if is_rm
      values[:unit_value] = (costs[0] * params["unit_real_state"]["products_quantity"].to_i).round(2)
      values[:total_value] = (costs[0] * params["unit_real_state"]["products_quantity"].to_i * params["unit_real_state"]["quantity"].to_i).round(2)
    else
      values[:unit_value] = ((costs[0] + costs[1]) * params["unit_real_state"]["products_quantity"].to_i).round(2)
      values[:total_value] = ((costs[0] + costs[1]) * params["unit_real_state"]["products_quantity"].to_i * params["unit_real_state"]["quantity"].to_i).round(2)
    end
    @unit_real_state_project = UnitRealState.create(unit_real_state_params.merge(values))
    @counter = @quotation.unit_real_states.length

    respond_to do |format|
      format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: @quotation, what_refresh: @what_refresh } }
    end
  end

  def update
    if params["unit_real_state"]["is_rm"] == "show"
      @quotation = Quotation.find(params["unit_real_state"]["quotation_id"])
      is_rm = @quotation.dispatch_commune.region.name = "Región Metropolitana" ? true : false
    else
      is_rm = params["unit_real_state"]["is_rm"]
      @quotation = check_quotation_token
    end
    costs = get_cost_rm_and_region(params["unit_real_state"]["products_quantity"].to_i)
    values = {}
    
    if is_rm
      values[:unit_value] = (costs[0] * params["unit_real_state"]["products_quantity"].to_i).round(2)
      values[:total_value] = (costs[0] * params["unit_real_state"]["products_quantity"].to_i * params["unit_real_state"]["quantity"].to_i).round(2)
    else
      values[:unit_value] = ((costs[0] + costs[1]) * params["unit_real_state"]["products_quantity"].to_i).round(2)
      values[:total_value] = ((costs[0] + costs[1]) * params["unit_real_state"]["products_quantity"].to_i * params["unit_real_state"]["quantity"].to_i).round(2)
    end
    @unit_real_state.update(unit_real_state_params.merge(values))

    render json: @quotation.unit_real_states.to_json
  end

  def update_show
    @quotation = Quotation.find(params["unit_real_state"]["quotation_id"])
    if params["unit_real_state"]["is_rm"] == "show"
      is_rm = @quotation.dispatch_commune.region.name = "Región Metropolitana" ? true : false
    else
      is_rm = params["unit_real_state"]["is_rm"]
      @quotation = check_quotation_token
    end
    costs = get_cost_rm_and_region(params["unit_real_state"]["products_quantity"].to_i)
    values = {}
    
    if is_rm
      values[:unit_value] = (costs[0] * params["unit_real_state"]["products_quantity"].to_i).round(2)
      values[:total_value] = (costs[0] * params["unit_real_state"]["products_quantity"].to_i * params["unit_real_state"]["quantity"].to_i).round(2)
    else
      values[:unit_value] = ((costs[0] + costs[1]) * params["unit_real_state"]["products_quantity"].to_i).round(2)
      values[:total_value] = ((costs[0] + costs[1]) * params["unit_real_state"]["products_quantity"].to_i * params["unit_real_state"]["quantity"].to_i).round(2)
    end
    @unit_real_state.update(unit_real_state_params.merge(values))

    respond_to do |format|
      format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: @quotation, what_refresh: @what_refresh } }
    end
  end

  def destroy
    @quotation = check_quotation_token
    @unit_real_state.destroy
    render json: @quotation.unit_real_states.to_json
  end

  def destroy_show
    @quotation = check_quotation_token
    quotation = @unit_real_state.quotation
    @unit_real_state.destroy

    respond_to do |format|
      format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: quotation, what_refresh: @what_refresh } }
    end
  end

  private

  def set_what_refresh
    @what_refresh = { installation_box: true,
      all_unit_real_states: true,
      dispatch_groups_container: false,
      dispatch_stats: false,
      all_config_unit_real_states: false,
      glosa: true
    }
  end

  def clp_to_UF_instalation_value()
    project_installation_values_aux = []
    ProjectInstallationValue.all.each do |indicator|
      project_installation_values_aux.push({
        min_amount: indicator["min_amount"],
        max_amount: indicator["max_amount"],
        cost_RM: CartHelper.clp_to_UF(indicator["cost_RM"]),
        cost_additional_region:  CartHelper.clp_to_UF(indicator["cost_additional_region"])
        })
    end
    project_installation_values_aux
  end

  def clp_to_UF_instalation_discount()
    project_installation_discounts_aux = []
    ProjectInstallationDiscount.all.each do |indicator|
      project_installation_discounts_aux.push({
        min_amount: CartHelper.clp_to_UF(indicator["min_amount"]),
        max_amount: CartHelper.clp_to_UF(indicator["max_amount"]),
        discount_percentage: indicator["discount_percentage"]
      })
    end
    project_installation_discounts_aux
  end

  def get_cost_rm_and_region(products_quantity)
    project_installation_values = clp_to_UF_instalation_value()
    cost_rm = 0
    cost_region = 0
    project_installation_values.each do |value|
      if products_quantity >= value[:min_amount] && products_quantity<=value[:max_amount]
        cost_rm = value[:cost_RM]
        cost_region = value[:cost_additional_region]
        break
      end
    end
    return [cost_rm, cost_region]
  end

  def set_unit_real_state
    @unit_real_state = UnitRealState.find(params[:id])
  end

  def unit_real_state_params
    params.require(:unit_real_state).permit(
      :name, 
      :quantity,
      :products_quantity,
      :quotation_id,
      :is_rm
    )
  end

end