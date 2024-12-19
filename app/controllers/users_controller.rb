class UsersController < ApplicationController
	before_action :authenticate_user!
	before_action :set_user, only: [:toggle, :edit, :destroy]
	before_action :set_paper_trail_whodunnit, only: [:toggle]
	load_and_authorize_resource

	def index
		if current_user.manager?
			@users = current_user.sale_channel.users.order('id DESC').paginate(page: params[:page], per_page: 10)
			@items = current_user.sale_channel.users.size
		elsif current_user.administrator? or current_user.is_finance_manager?
			@users = User.all.order('id DESC').paginate(page: params[:page], per_page: 10)
			@items = User.all.size
		elsif current_user.is_finance?
			@users = User.joins(:role).where('roles.name = ? OR roles.name = ?','Manager Finanzas','Finanzas').paginate(page: params[:page], per_page: 10)
			@items = User.joins(:role).where('roles.name = ? OR roles.name = ?','Manager Finanzas','Finanzas').size
		elsif current_user.is_manager_instalation?
			@users = User.joins(:role).where('roles.name = ? OR roles.name = ?','Manager Instalación','Instalación').paginate(page: params[:page], per_page: 10)
			@items = User.joins(:role).where('roles.name = ? OR roles.name = ?','Manager Instalación','Instalación').size
		elsif current_user.is_manager_dispatch?
			@users = User.joins(:role).where('roles.name = ? OR roles.name = ?','Manager Despacho','Despacho').paginate(page: params[:page], per_page: 10)
			@items = User.joins(:role).where('roles.name = ? OR roles.name = ?','Manager Despacho','Despacho').size
		end
	end

	def new
		@user = User.new
		set_dropdowns
		@roles = @roles.pluck(:name, :id)
	end

	def edit
		set_dropdowns
		roles = @roles.pluck(:name, :id)
		user_roles = current_user.custom_roles.map{|r| [r.role.name, r.role.id]}
		@roles = roles | user_roles
	end

	def destroy
		respond_to do |format|
			if @user.destroy
				format.html{redirect_to users_path, notice: 'Usuario eliminado con éxito.'}
			else
				format.html{redirect_to users_path, alert: 'Error: '+@user.errors.full_messages.join(',')}
			end
		end
	end

	def update
		respond_to do |format|
			if @user.update(user_params)
				@user.update(@user.custom_roles.first.attributes.except("id","user_id", "created_at", "updated_at"))
				format.html{redirect_to users_path, notice: 'Usuario actualizado con éxito.'}
			else
				format.html{redirect_to edit_user_path(@user), alert: 'Error: '+@user.errors.full_messages.join(',')}
			end
		end
	end

	def create_user
		params[:user][:password] = User.default_pass
		params[:user][:active] = false if current_user.cant_create
		user = User.new(user_params)
		respond_to do |format|
			if user.save
				user.update(user.custom_roles.first.attributes.except("id","user_id", "created_at", "updated_at"))
				UserMailer.welcome_mail(user).deliver_later
				format.html{redirect_to users_path, notice: 'Usuario creado con éxito.'}
			else
				format.html{redirect_to new_user_path, alert: 'Error: '+user.errors.full_messages.join(',')}
			end
		end
	end

	def upload_users
		
	end

	def load_users
		success, session[:errors] = User.load_from_excel(params[:file])
		respond_to do |format|
			if success and session[:errors].empty?
				format.html{redirect_to request.env["HTTP_REFERER"], notice: 'Usuarios cargados con éxito.'}
			else
				format.html{redirect_to request.env["HTTP_REFERER"], alert: 'Ha ocurrido un problema al cargar los usuarios.'}
			end
		end 
	end

	def download_users
		@users = User.all.order(lastname: :asc)
		respond_to do |format|
			format.xlsx{render xlsx: 'download_users', filename: "plantilla_usuarios_#{Date.today.strftime("%d/%m/%Y")}.xlsx"}
		end
	end

	def toggle
		respond_to do |format|
			if @user.toggle!(:active)
				format.js{ (@success = true).to_json }
			else
				format.js{ (@success = false).to_json }
			end
		end
	end

	def template
		send_file(
			"#{Rails.root}/public/resources/plantilla_usuarios.xlsx",
			filename: "plantilla_usuarios.xlsx",
			type: "application/xlsx"
			)
	end

	def change_role
		session[:can_navigate] = false
		redirect_to choose_role_path
	end

	def choose_role
		redirect_to root_path if session[:can_navigate]
		@roles = current_user.custom_roles
	end

	def set_role
		custom_r = CustomRole.find_by(id: params[:custom_role_id])
		current_user.update(custom_r.attributes.except("id","user_id", "created_at", "updated_at"))
		session[:can_navigate] = true
		redirect_to root_path
	end

	def search
		@users = User.where(
		"
		  translate(LOWER(name),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
		  translate(LOWER(lastname),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
		  translate(LOWER(second_lastname),'áâãäåāăąÁÂÃÄÅĀĂĄèééêëēĕėęěĒĔĖĘĚìíîïìĩīĭÌÍÎÏÌĨĪĬóôõöōŏőÒÓÔÕÖŌŎŐùúûüũūŭůÙÚÛÜŨŪŬŮñÑ','aaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeiiiiiiiiiiiiiiiiooooooooooooooouuuuuuuuuuuuuuuunN') ilike ? or
			email ilike ?
		",
			'%'+ActiveSupport::Inflector.transliterate(params[:search_user]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_user]).downcase+'%',
			'%'+ActiveSupport::Inflector.transliterate(params[:search_user]).downcase+'%', '%'+ActiveSupport::Inflector.transliterate(params[:search_user]).downcase+'%'
		)
	
		@items = @users.size
		respond_to do |format|
			format.html do 
				@users = @users.paginate(page: params[:page], per_page: 10)
				render 'index'
			end
			format.json 
		end
	end	

	private

	def set_dropdowns
		if current_user.manager?
			@roles = Role.where(name: ["Manager","Seller"])
			@sale_channels = SaleChannel.where(name: current_user.sale_channel.name)
		elsif current_user.administrator? or current_user.is_finance_manager?
			@roles = Role.all
			@sale_channels = SaleChannel.all
		elsif current_user.is_finance?
			@roles = Role.where(name: ["Finanzas","Manager Finanzas"])
		elsif current_user.is_manager_instalation?
			@roles = Role.where(name: ["Instalación","Manager Instalación"])
		elsif current_user.is_manager_dispatch?
			@roles = Role.where(name: ["Despacho","Manager Despacho"])
		end
	end

	def set_user
		@user = User.find_by(id: params[:id])
	end

	def user_params
		params.require(:user).permit(
			:role_id,
			:name, 
			:lastname, 
			:second_lastname,
			:email, 
			:phone, 
			:cost_center_id,
			:shop,
			:workday,
			:password,
			:sale_channel_id,
			:miele_role_id,
			:active,
			custom_roles_attributes: [:role_id, :sale_channel_id, :cost_center_id, :id, :_destroy]
			)
	end
end