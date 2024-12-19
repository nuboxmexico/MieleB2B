class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: [:sign_in, :return_url, :webpay_final_url, :webpay_success, :webpay_error, :webpay_nullify, :already_paid, :terms_and_conditions, :download_terms]
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_role, except: [:choose_role, :set_role, :change_role, :destroy_user_session]
  protect_from_forgery prepend: true
  #before_action :check_quotation_token

  rescue_from Apipie::ParamError do |e|
    render json: {error: 'Hubo un error en el request: '+e.message, failed: []}, status: :internal_server_error
  end


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: 'Acceso no autorizado.'
  end

  def check_quotation_token
    Quotation.create_cookie(cookies, current_user)
    @quotation_request = Quotation.find_by(guest_token: cookies[:quotation_request])
  end

  def new_quotation_pdf(quotation)
    return :template    => 'quotations/new_quotation.pdf.erb', 
    :pdf         => 'documento_' + quotation.id.to_s,
    :disposition => 'inline',
    :layout      => 'document_in_pdf.html',
    :title       => 'documento_' + quotation.id.to_s,
    :page_size   => 'Letter',
    :locals      => { quotation: quotation },
    :margin => { top:    25,
     bottom: 25 ,
     left:   20,   
     right:  20 },
     :header => {
      :html => {:template => 'layouts/_header_pdf.html.erb'}
    }
  end

  private 

  def respond_js
    respond_to do |format|
      format.js
    end
  end
  
  def send_template
    send_file("#{Rails.root}/public/resources/#{@filename}.xlsx", filename: "#{@filename}.xlsx", type: "application/xlsx")
  end
  
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def check_role
    if current_user and current_user.custom_roles.size > 1 and !session[:can_navigate]
      session[:can_navigate] = false
      redirect_to choose_role_path
    elsif current_user
      session[:can_navigate] = true
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :lastname, :role_id, :cost_center_id, :phone, :email, :workday, :shop])
  end

  # Authenticate the user with token based authentication
  def authenticate
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    if current_user.nil?
      request.headers["Authorization"]= "Bearer #{request.headers["User-Token"]}" if request.headers["Authorization"].nil?
      authenticate_with_http_token do |token, options|
        @current_user = User.find_by(api_key: token)
        @current_user = User.find_by(authentication_token: token) if @current_user.nil?   
      end
      @current_user
    else
      current_user
    end
  end

  

  def render_unauthorized(realm = "Application")
    self.headers["WWW-Authenticate"] = %(Token realm="#{realm}")
    render json: '{"error": "Ingreso no autorizado"}', status: :unauthorized
  end
end
