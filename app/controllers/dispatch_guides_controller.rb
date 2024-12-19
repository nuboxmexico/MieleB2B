class DispatchGuidesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dispatch_guide

  def destroy
    quotation = @dispatch_guide.quotation
    respond_to do |format|
      if ['Despacho', 'Manager Despacho'].include?(current_user.role.name) and quotation.post_in_preparation_status? and @dispatch_guide.destroy
        format.html{redirect_to quotation, notice: 'Guía de despacho eliminada con éxito.'}
      else
        format.html{redirect_to quotation, alert: 'Hubo un problema eliminando la guía de despacho.'}
      end
    end
  end

  private

    def set_dispatch_guide
      @dispatch_guide = DispatchGuide.find(params[:id])
    end
end