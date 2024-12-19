class LeadsController < ApplicationController
  before_action :set_lead, only: [:show, :edit, :update, :to_quotation]
  before_action :set_cart, only: [:to_quotation]

  def index
    @query = Lead.not_in_negotiation.ransack(params[:q])
    @leads = @query.result.paginate(page: params[:page], per_page: 12)
  end

  def new
    @lead = Lead.new
    @lead.products << LeadProduct.new
  end

  def create
    lead = Lead.new(lead_params)
    lead.add_attachments(params[:lead][:attachments])
    respond_to do |format|
      if lead.save
        format.html{ redirect_to lead, notice: 'Lead creado con éxito' }
      else
        format.html{ redirect_to new_lead_path, alert: lead.errors.full_messages.join(', ') }
      end
    end
  end

  def show
    @existing_skus = @lead.existing_skus
  end

  def edit
  end

  def update
    respond_to do |format|
      if @lead.add_attachments(params[:lead][:attachments]) and @lead.update(lead_params)
        format.html{ redirect_to @lead, notice: 'Lead actualizado con éxito' }
      else
        format.html{ redirect_to edit_lead_path(@lead), alert: @lead.errors.full_messages.join(', ') }
      end
    end
  end

  def add_product_form
    @tag_id = params[:tag_id].to_i
    @product = LeadProduct.new
    @currency = params[:currency]
    respond_to do |format|
      format.js
    end
  end

  def download
    start_date = DateTime.parse(params[:start_date])
    finish_date = DateTime.parse(params[:finish_date])
    @leads = Lead.where(created_at: start_date.beginning_of_day..finish_date.end_of_day)
    respond_to do |format|
      format.xlsx {render xlsx: 'download', filename: "Leads_#{Date.today.strftime("%d-%m-%Y")}.xlsx"}
    end
  end

  def to_quotation
    lead_state = QuotationState.find_by(name: 'Lead')
    quotation = Quotation.new(project_name: @lead.name, 
                              real_state_name: @lead.real_state_name,
                              lead: @lead,
                              user: current_user,
                              currency: @lead.currency,
                              quotation_state: lead_state)
    quotation.set_products_from_lead(@lead)
    respond_to do |format|
      if quotation.save and @lead.in_negotiation!
        @cart.reset_with_new_products(quotation, current_user)
        format.html{ redirect_to edit_quotation_path(@cart.quotation) }
      else
        format.html{ redirect_to lead_path(@lead), alert: 'Ocurrió un error al intentar crear la cotización a partir del lead' }
      end
    end
  end

  private
    def lead_params
      params.require(:lead).permit(
        :name,
        :real_state_name,
        :contacts,
        :project_address,
        :start_date_estimated,
        :currency,
        :observations,
        :status,
        products_attributes: [:id, :sku, :name, :quantity, :unit_price]
      )
    end

    def set_lead
      @lead = Lead.find(params[:id])
    end

    def set_cart
      @cart = Cart.find_or_create_by(user: current_user)
    end
end
