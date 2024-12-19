class Api::V1::TestsController < ApplicationController

    skip_before_action :authenticate_user!
    before_action :authenticate

    api :GET, "/v1/visits/:id/technicians", "Lista los técnicos de la visita"
    param :id, String, :desc => "ID de la visita a consultar"
    def prueba
        render html: 'Probando la api'.html_safe
    end 
end
