require 'rails_helper'
#, js: true do save_and_open_screenshot
describe 'User', type: :feature do 
  # USUARIOS
  let(:user){create(:user)}
  let(:manager_user){create(:manager_user)}
  let(:manager_finance_user){create(:manager_finance_user)}
  let(:manager_dispatch_user){create(:manager_dispatch_user)}
  let(:manager_instalation_user){create(:manager_instalation_user)}
  let(:foreign_user){create(:foreign_user)}
  let(:seller_user){create(:seller_user)}

  context 'Autentication' do
    ### AUTENTIFICACIÓN DE USUARIO
    it 'login with created user', js: true do
      visit                     root_path
      expect(page).to           have_current_path(new_user_session_path)
      fill_in 'user_email'    , with: user.email
      fill_in 'user_password' , with: '123456'
      find('input[type="submit"]').click
      expect(page).to           have_current_path(root_path)
      expect(page).to           have_content('Sesión iniciada.')
      first('.sidebar-toggle').click
      expect(page).to           have_content(user.name)
    end

    it 'logout with created user', js: true do 
      login_as(user, scope: :user)
      visit root_path
      expect(page).to have_current_path(root_path)
      first('.sidebar-toggle').click
      first('.sign-out', visible: false).click
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'login when is not active', js: true do 
      deactivated = create(:user_deactivated)
      visit                     root_path
      expect(page).to           have_current_path(new_user_session_path)
      fill_in 'user_email'    , with: deactivated.email
      fill_in 'user_password' , with: '123456'
      find('input[type="submit"]').click
      expect(page).to           have_current_path(new_user_session_path)
      expect(page).to           have_content('Esta cuenta está desactivada')
    end
  end

  context 'Password' do
    it 'recovery from home page pass', js: true do
      ActionMailer::Base.deliveries = []
      visit root_path
      click_link('¿Olvidaste tu contraseña?')
      expect(page).to have_current_path('/users/password/new')
      expect(page).to have_content('¿Olvidaste tu contraseña?')
      fill_in 'user_email', with: user.email
      first('.btn-login').click
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('Recibirás un correo con instrucciones sobre cómo cambiar tu contraseña en unos pocos minutos.')
      
      expect(ActionMailer::Base.deliveries.count).to be 1
    end

    it 'recovery from home page fail', js: true do
      ActionMailer::Base.deliveries = []
      visit root_path
      click_link('¿Olvidaste tu contraseña?')
      expect(page).to have_current_path('/users/password/new')
      expect(page).to have_content('¿Olvidaste tu contraseña?')
      fill_in 'user_email', with: 'oferusat@gmail.com'
      first('.btn-login').click
      expect(page).to have_current_path('/users/password')
      expect(page).to have_content('Correo Electrónico no se ha encontrado')
      expect(ActionMailer::Base.deliveries.count).to eq 0
    end
  end

  context 'administration' do
    before do
      login_as(user, scope: :user)
      ActionMailer::Base.deliveries = []
    end

    it 'load from excel', js: true do
      create(:seller_role)
      create(:finance_role)
      create(:manager_role)
      create(:sale_channel)
      create(:own_retail_sale_channel)
      create(:miele_role)
      create(:miele_role, code: '2020')
      create(:miele_role, code: '116')
      create(:miele_role, code: '14')
      create(:cost_center, code: 123, name: 'Mieler')
      create(:cost_center, code: 999, name: 'Instalación')
      create(:cost_center, code: 888, name: 'vitacura')
      create(:cost_center, code: 144, name: 'Valpo')
      visit upload_users_path
      expect(page).to have_current_path(upload_users_path)
      attach_file('users_upload', Rails.root + "spec/aux/plantilla_usuarios.xlsx", make_visible: true)
      click_button('Cargar usuarios')
      expect(page).to have_current_path(upload_users_path)
      
      expect(User.first.name).to eq 'Not prueba'
      expect(User.first.shop).to eq 'Costanera'
      expect(User.first.administrator?).to eq true
      expect(User.first.sale_channel).to eq nil
      expect(User.second.name).to eq 'Prueba 2'
      expect(User.second.email).to eq 'prueba@garage.net'
      expect(User.second.seller?).to eq true
      expect(User.second.sale_channel.name).to eq 'Own Retail'
      expect(User.third.email).to eq 'prueba2@garage.net'
      expect(User.third.cost_center.code).to eq 999
      expect(User.third.is_finance?).to eq true
      expect(User.third.sale_channel).to eq nil
      expect(User.fourth.email).to eq 'prueba3@garage.net'
      expect(User.fourth.miele_role.name).to eq 'Miele Test'
      expect(User.fourth.is_mca?).to eq true
      expect(ActionMailer::Base.deliveries.count).to eq 3
    end

    it 'download template for upload', js: true do
      Capybara.current_driver = :webkit
      visit upload_users_path
      expect(page).to have_current_path(upload_users_path)
      first('#users_template').click
      expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_usuarios.xlsx"'
      Capybara.use_default_driver
    end

    it 'create from admin panel', js: true do
      create(:sale_channel)
      create(:cost_center)
      visit new_user_path
      expect(page).to have_current_path(new_user_path)

      fill_in 'user_email', with: 'prueba@garage.net'
      fill_in 'user_name', with: 'Test name'
      fill_in 'user_lastname', with: 'Lastest'
      fill_in 'user_second_lastname', with: 'Materno'
      fill_in 'user_phone', with: '987654321'
      fill_in 'user_shop', with: 'Costanera'

      within first('#user-role') do 
        find('.select2-container').click
      end

      find(".select2-search__field").set('Admin')

      within ".select2-results__options" do
        find('li', text: 'Administrador').click
      end

      first('#submit-user').click

      expect(page).to have_current_path(users_path)
      expect(page).to have_content('Usuario creado con éxito.')
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(User.last.email).to eq 'prueba@garage.net'
      expect(User.last.cost_center.code).to eq 36
    end

    it 'download users', js: true do 
      Capybara.current_driver = :webkit
      visit users_path
      expect(page).to have_current_path(users_path)
      first('#massive-download').click
      expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_usuarios_'+Date.today.strftime("%d/%m/%Y")+'.xlsx"'
      Capybara.use_default_driver
    end

    it 'edit user', js: true do 
      Timecop.freeze(Date.new(2020, 07, 15))
      create(:manager_user)
      visit users_path
      expect(page).to have_current_path(users_path)
      expect(page).to have_content('618 Vitacura Manager Test manager@test.net 987654321 15/07/2020 Manager E-commerce X')
      first('.fa-user-edit').click
      expect(page).to have_current_path(edit_user_path(User.last))
      expect(page).to have_content('Editar usuario Manager Test')
      fill_in 'user_lastname', with: 'Tost'
      first('#submit-user').click
      expect(page).to have_current_path(users_path)
      expect(page).to have_content('618 Vitacura Manager Tost manager@test.net 987654321 15/07/2020 Manager E-commerce X')
      expect(page).to have_content('Usuario actualizado con éxito.')
      Timecop.return
    end

    it 'delete user', js: true do 
      Timecop.freeze(Date.new(2020, 07, 15))
      create(:manager_user)
      visit users_path
      expect(page).to have_current_path(users_path)
      expect(page).to have_content('618 Vitacura Manager Test manager@test.net 987654321 15/07/2020 Manager E-commerce X')
      first('#delete-2').click
      first('.swal2-confirm').click
      expect(page).to have_current_path(users_path)
      expect(page).not_to have_content('618 Vitacura Manager Tost manager@test.net 987654321 15/07/2020 Manager E-commerce X')
      expect(page).to have_content('Usuario eliminado con éxito.')
      expect(User.all.size).to eq 1
      Timecop.return
    end

    it 'visit index page', js: true do
      visit users_path
      expect(page).to have_current_path(users_path)
      expect(page).to have_content('618 Vitacura Administrador Test oferusat@gmail.com 987654321')
      expect(page).to have_content(Date.today.strftime("%d/%m/%Y"))
      expect(page).to have_content('Mostrando registros del 1 al 1 de un total de 1 usuarios.')
      expect(page).to have_css("#massive-load", text: "Carga masiva de usuarios")
      expect(page).to have_css("#new-user", text: "Crear usuario")
    end

    it 'deactivate a user', js: true do 
      visit users_path
      expect(page).to have_current_path(users_path)
      expect(page).to have_content('618 Vitacura Administrador Test oferusat@gmail.com 987654321')
      first('.slider').click
      wait_for_ajax
      expect(page).to have_content('Usuario actualizado')
      expect(User.last.active).to eq false
      expect(User.last.versions.size).to eq 3
    end
  end

  context 'Actions with foreign user' do 
    before do
      login_as(foreign_user, scope: :user)
    end

    it 'visit root path', js: true do 
      visit root_path
      expect(page).to have_current_path(business_units_path)
    end

  end

  context 'Actions with Seller user' do 
    before do
      login_as(seller_user, scope: :user)
    end

    it 'visit root path', js: true do 
      visit root_path
      expect(page).to have_current_path(business_units_path)
    end
  end

  context 'Actions with finance user' do 

    before do
      login_as(manager_finance_user, scope: :user)
    end

    it 'visit root path', js: true do 
      visit root_path
      expect(page).to have_current_path(quotations_path)
    end

    it 'visit users index', js: true do
      visit users_path
      expect(page).to have_current_path(users_path)
      expect(all('.user-row').length).to eq 1
    end

    it 'create new user', js: true do 
      create(:sale_channel)
      create(:finance_role)
      visit new_user_path
      expect(page).to have_current_path(new_user_path)
      within '.role-div' do
        find('.select2-container').click
      end
      expect(page).to have_content('Finanzas')
      expect(page).to have_content('Manager Finanzas')
    end

  end

  context 'Actions with Manager user' do 
    before do
      login_as(manager_user, scope: :user)
    end

    it 'visit root_path', js: true do 
      visit root_path
      expect(page).to have_current_path(root_path)
    end

    it 'visit users index', js: true do
      visit users_path
      expect(page).to have_current_path(users_path)
      expect(all('.user-row').length).to eq 1
    end

    it 'create new user', js: true do 
      create(:seller_role)
      visit new_user_path
      expect(page).to have_current_path(new_user_path)
      within '.role-div' do
        find('.select2-container').click
      end
      expect(page).to have_content('Manager')
      expect(page).to have_content('Seller')
    end
  end

  context 'Actions with dispatch user' do 

    before do
      login_as(manager_dispatch_user, scope: :user)
    end

    it 'visit root path', js: true do 
      create(:en_preparacion)
      visit root_path
      expect(page).to have_current_path(quotations_path)
    end

    it 'visit users index', js: true do
      visit users_path
      expect(page).to have_current_path(users_path)
      expect(all('.user-row').length).to eq 1
    end

    it 'create new user', js: true do 
      create(:dispatch_role)
      visit new_user_path
      expect(page).to have_current_path(new_user_path)
      within '.role-div' do
        find('.select2-container').click
      end
      expect(page).to have_content('Despacho')
      expect(page).to have_content('Manager Despacho')
    end

  end

  context 'Actions with instalation user' do 

    before do
      login_as(manager_instalation_user, scope: :user)
    end

    it 'visit root path', js: true do 
      create(:despachado)
      visit root_path
      expect(page).to have_current_path(quotations_path)
    end

    it 'visit users index', js: true do
      visit users_path
      expect(page).to have_current_path(users_path)
      expect(all('.user-row').length).to eq 1
    end

    it 'create new user', js: true do 
      create(:dispatch_role)
      visit new_user_path
      expect(page).to have_current_path(new_user_path)
      within '.role-div' do
        find('.select2-container').click
      end
      expect(page).to have_content('Instalación')
      expect(page).to have_content('Manager Instalación')
    end

  end
end
