class Api::V1::QuotationsController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :authenticate

    before_action :set_quotation, only: [:get_current_status]

    api :GET, "/v1/quotations/:id/current_status", "Muestra el estado actual de una cotización"
    param :id, String, :desc => "ID de la cotización a consultar el estado actual"
    
    def get_current_status
        if @quotation
            response = { status: @quotation.get_state }
            render json: response.to_json, status: :ok
        else 
            response = { error: 'Not found' }
            render json: response.to_json, status: :not_found
        end
    end

    private

    def set_quotation
        @quotation = Quotation.find_by(id: params[:id])
    end
end
