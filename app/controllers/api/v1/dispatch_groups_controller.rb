class Api::V1::DispatchGroupsController < ApplicationController

    skip_before_action :authenticate_user!
    before_action :authenticate
    before_action :set_dispatch_group, only: [:close_dispatch_group]

    api :POST, "/v1/dispatch_groups/:id/close", "Finaliza un grupo de envío despachado"
    param :visit_report_url, String, :desc => "Url del reporte de la visita"    
    def close_dispatch_group
        response = {}
        response["data"] = @dispatch_group.nil? ? {error: "No se ha encontrado un dispatch_group asociado al id."} : @dispatch_group
        code = @dispatch_group.nil? ? :not_found : :ok
        detail_quotation_products = @dispatch_group.detail_quotation_products
        quotation = @dispatch_group.quotation
        dispatch_number = get_number_dispatch_group(quotation)
        reception_type = 0
        QuotationMailer.finish_visit_alert(quotation["code"], dispatch_number, quotation["id"]).deliver_later if @dispatch_group
        detail_quotation_products.each do |detail|
            reception_type = detail["state"] == "Entregado" ? 0 :2
        end
        if !@dispatch_group.nil? && @dispatch_group.update(visit_report_url: params[:visit_report_url] , reception_type: reception_type) && @dispatch_group.to_state_from_reception_type
            response["data"] = @dispatch_group.reload
            
			render json:  response.to_json, status: code
        else
            render json:  response.to_json, status: code
        end
    end 

    private
        def set_dispatch_group
            @dispatch_group = DispatchGroup.find_by(id: params[:id])
        end

        def get_number_dispatch_group(quotation)
            dispatch_groups = quotation.dispatch_groups.order('created_at asc')
            dispatch_group_ids = []
            dispatch_groups.each do |dp|
                unless dispatch_group_ids.include? dp["id"]
                    dispatch_group_ids.push(dp["id"])
                end
            end
            dispatch_number = 0
            dispatch_group_ids.each_with_index do |id, index|
                dispatch_number = index + 1 if id == @dispatch_group["id"]
            end
            dispatch_number
        end
end
