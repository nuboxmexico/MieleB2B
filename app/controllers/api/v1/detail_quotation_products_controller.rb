class Api::V1::DetailQuotationProductsController < ApplicationController

    skip_before_action :authenticate_user!
    before_action :authenticate
    before_action :set_detail_quotation_product_with_customer_product_id, only: [:update_state]

    api :PATCH, "/v1/detail_quotation_products/update_state", "Actualiza el estado de un detail_quotation_product"
    param :customer_product_id, String, :desc => "id del customer_product"
    param :serial_id, String, :desc => "EAN deñ customer product (serial_id)"
    param :state, String, :desc => "Estado del customer_product"    
    def update_state
        response = {}
        response["data"] = @detail_quotation_product.nil? ? {error: "No se ha encontrado un detail_customer_product asociado al id."} : @detail_quotation_product
        code = @detail_quotation_product.nil? ? :not_found : :ok
        if !@detail_quotation_product.nil? && @detail_quotation_product.update(state: params[:state], serial_id: params[:serial_id])
            dispatch_group = @detail_quotation_product.dispatch_group
            dispatch_group.check_states_and_then_change_state
			response["data"] = @detail_quotation_product.reload
			render json:  response.to_json, status: code
        else
            render json:  response.to_json, status: code
        end
    end 

    private
        def set_detail_quotation_product_with_customer_product_id
            @detail_quotation_product = DetailQuotationProduct.find_by(core_id: params[:customer_product_id])
        end
end
