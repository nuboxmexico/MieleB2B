Rails.application.routes.draw do
  resources :detail_quotation_products
  # ROOT PATH
  authenticate :user, lambda { |u| u.administrator? } do
    apipie
  end
  root 'home#index'
  # resources
  devise_for :users, :controllers => {:sessions => 'users/sessions'}
  get '/users/search', to: 'users#search'
  resources :users
  get '/choose_role', to: 'users#choose_role', as: 'choose_role'
  get '/change_role', to: 'users#change_role', as: 'change_role'
  post '/set_role', to: 'users#set_role', as: 'set_role'
  
  resources :promotional_codes
  resources :banners

  # DASHBOARD
  get '/home/filter', to: 'home#filter', as: 'filter_home'
  # BANNERS
  get '/banner/reference', to: 'banners#reference_banner', as: 'reference_banner'
  # PRODUCTOS
  get '/business_units', to: 'products#business_units', as: 'business_units'
  get  '/:business_unit/products', to: 'products#index'     , as: 'products' 
  get  '/search', to: 'products#search', as: 'search_products'
  get  '/product/:sku', to: 'products#show', as: 'product'
  get  '/product/bstock/:sku', to: 'products#show', bstock: true, as: 'bstock_product'
  patch '/product/:id', to: 'products#update', as: 'update_product'
  get '/cart/:id/mandatories_by_instalation/:instalation_id', to: 'cart#mandatories_by_instalation', as: 'mandatories_by_instalation'
  get '/bstocks', to: 'products#bstock', as: 'bstocks'
  post '/product/destroy', to: 'products#destroy', as: 'delete_product'
  patch '/product/:sku/syncronize_with_miele_core', to: 'products#synchronize_one_product_with_miele_core', as: 'synchronize_one_product_with_miele_core'
  
  # COTIZACIONES
  get 'quotations/:id/resumen'     , to: 'quotations#resumen' , as: 'quotation_resumen'
  get '/quotations/search'         , to: 'quotations#search', as: 'search_quotations'
  post '/quotations/:id/check_dispatch/:commune', to: 'quotations#check_dispatch', as: 'check_dispatch'
  post '/quotation/:id/update_payment_info', to: 'quotations#update_payment_info', as: 'update_payment_info'
  get '/quotations/:id/pay_debt', to: 'quotations#pay_debt', as: 'pay_debt'
  post '/quotation/:id/reactivate', to: 'quotations#reactivate', as: 'reactivate_quotation'
  post '/quotation/:id/reactivate_for_project', to: 'quotations#reactivate_for_project', as: 'reactivate_for_project'
  post '/quotation/:id/update_quotation', to: 'quotations#update_quotation', as: 'update_custom_quotation'
  post '/quotation/get_dispatch_cost', to: 'quotations#get_dispatch_cost'
  post '/quotation/get_dispatch_cost_show', to: 'quotations#get_dispatch_cost_show'
  post '/quotation/set_dispatch_value', to: 'quotations#set_dispatch_value'
  post '/quotation/set_installation_value', to: 'quotations#set_installation_value'
  patch '/quotation/:id/update_total_from_view', to: 'quotations#update_total_from_view'


  #normal flow
  post '/quotation/:id/finish', to: 'quotation_flow#cancel_quotation', as: 'cancel_quotation'
  post '/quotation/:id/activate', to: 'quotation_flow#activate', as: 'activate_quotation'
  post '/quotation/:id/dispatch', to: 'quotation_flow#dispatch_activation', as: 'dispatch_quotation'
  post '/quotation/:id/dispatch_confirm', to: 'quotation_flow#dispatch_confirm', as: 'dispatch_confirm_quotation'
  post '/quotation/:id/instalation', to: 'quotation_flow#instalation', as: 'instalation_quotation'
  post '/quotation/:id/activate_home_program', to: 'quotation_flow#activate_home_program', as: 'activate_home_program_quotation'
  post '/quotation/:id/load_billing_documents', to: 'quotation_flow#load_billing_documents', as: 'load_billing_documents'
  #project flow
  post '/quotation/:id/negotiation_quotation', to: 'quotation_flow#negotiation_quotation', as: 'negotiation_quotation'
  post '/quotation/:id/close_quotation', to: 'quotation_flow#close_quotation', as: 'close_quotation'
  post '/quotation/:id/lead_quotation', to: 'quotation_flow#lead_quotation', as: 'lead_quotation'
  #retail flow
  post '/quotation/:id/activate_retail', to: 'quotation_retail#activate_retail', as: 'activate_retail'
  post '/quotation/:id/activate_finance_retail', to: 'quotation_retail#activate_finance_retail', as: 'activate_finance_retail'
  post '/quotation/:id/update_quantities', to: 'quotation_retail#update_quantities', as: 'update_quantities'
  post 'quotations/:id/new_version', to: 'quotations#new_version', as: :new_version
  delete 'quotations/:id', to: 'quotations#destroy', as: :delete_version
  get 'quotations/checkout', to: 'quotations#checkout'
  post 'quotations/checkout_instalation', to: 'quotations#checkout_instalation', as: 'checkout_instalation'
  get 'quotations/:id/send_dispatch_configuration_alert', to: 'quotations#send_dispatch_configuration_alert', as: :send_dispatch_configuration_alert
  patch '/set_instalation_check', to: 'quotations#set_instalation_check'
  get 'quotations/:id/unit_real_states', to: 'quotations#get_unit_real_states'


  resources :quotations, only: [:index, :new, :create, :show, :update, :edit]
  # CARRITO
  get  '/cart', to: 'cart#index', as: 'cart'
  post  '/cart/from_quotation', to: 'cart#from_quotation', as: 'cart_from_quotation'
  post '/cart/add_mandatory_to_cart', to: 'cart#add_mandatory_to_cart', as: 'add_mandatory_to_cart'
  post '/cart/apply_discount', to: 'cart#apply_discount', as: 'apply_discount'
  post 'add_product/:id'           , to: 'cart#add_product'   , as: 'add_product_to_cart'
  post '/add_product_bstock/:id', to: 'cart#add_product_bstock', as: 'add_product_bstock'
  post 'minus_product/:id'         , to: 'cart#minus_product' , as: 'minus_product_to_cart'
  post 'plus_product/:id'          , to: 'cart#plus_product'  , as: 'plus_product_to_cart'
  delete '/cart/empty'               , to: 'cart#empty'         , as: 'empty_cart'
  delete '/remove_product/:id'     , to: 'cart#remove_product', as: 'remove_product'
  post '/change_payment/:percent'  , to: 'cart#change_percent', as: 'change_percent'
  post '/apply_promotion/:type/:id'      , to: 'cart#apply_promotion', as: 'apply_promotion'
  post '/set_dispatch/:id/:value', to: 'cart#set_dispatch', as: 'set_dispatch'
  post '/set_instalation/:id', to: 'cart#set_instalation', as: 'set_instalation'
  get 'cart/update_totals'
  post 'cart/update_item_price'
  post 'cart_items/calculate_margen', to: "cart#calculate_margen"

  #carga de datos
  get '/data_upload'               , to: 'data_upload#upload_info', as: 'upload_info'
  post '/upload/product_photos'    , to: 'data_upload#load_photos', as: 'upload_product_photos'
  post '/upload/mandatory_products', to: 'data_upload#load_mandatory', as: 'upload_mandatory'
  post '/upload/products'          , to: 'data_upload#load_products', as: 'upload_products'
  post '/upload/discounts', to: 'data_upload#load_discounts', as: 'upload_discounts'
  post '/upload/addressees', to: 'data_upload#load_addressees', as: 'upload_addressees'
  post '/upload/stock', to: 'data_upload#load_stock', as: 'upload_stock'
  post '/upload/technical_images', to: 'data_upload#load_technical_images', as: 'upload_technical_images'
  post '/upload/load_comparator_info', to: 'data_upload#load_comparator_info', as: 'load_comparator_info'
  post '/upload/load_homologate_tnr', to: 'data_upload#load_homologate_tnr', as: 'load_homologate_tnr'
  post 'upload/load_oc_retail', to: 'data_upload#load_oc_retail', as: 'load_oc_retail'
  post 'upload/load_quotation_project', to: 'data_upload#load_quotation_project', as: 'load_quotation_project'
  post 'upload/load_cost_center', to: 'data_upload#load_cost_center', as: 'load_cost_center'
  post '/upload/load_miele_roles', to: 'data_upload#load_miele_roles', as: 'load_miele_roles'
  post '/upload/commission_levels', to: 'data_upload#load_commission_levels', as: 'load_commission_levels'
  post '/upload/load_project_installation_value', to: 'data_upload#load_project_installation_value', as: 'load_project_installation_value'
  post '/upload/load_project_installation_discount', to: 'data_upload#load_project_installation_discount', as: 'load_project_installation_discount'
  post '/upload/load_dispatch_rule', to: 'data_upload#load_dispatch_rule', as: 'load_dispatch_rule'
  post '/upload/save_margen', to: 'data_upload#load_save_margen', as: 'load_save_margen'


  patch '/update/customer_core_ids', to: 'data_upload#update_customer_core_ids', as: 'update_customer_core_ids'
  patch '/update/product_core_ids', to: 'data_upload#update_product_core_ids', as: 'update_product_core_ids'
  patch '/update/synchronizeProductsWithMieleCore', to: 'data_upload#synchronizeProductsWithMieleCore', as: 'synchronize_products_with_miele_core'

  get '/download/stock', to: 'data_upload#download_stock', as: 'download_stock'
  get '/download/products_template', to: 'data_upload#download_products', as: 'download_products'
  get '/download/discounts', to: 'data_upload#download_discounts', as: 'download_discounts'
  get '/download/addressees', to: 'data_upload#download_addressees', as: 'download_addressees'
  get '/download/commissions_table', to: 'data_upload#download_commissions_table', as: 'download_commissions_table'
  get '/download/cost_center', to: 'data_upload#download_cost_center', as: 'download_cost_center'
  get '/download/miele_roles', to: 'data_upload#download_miele_roles', as: 'download_miele_roles'
  get '/download/tnr_homologated', to: 'data_upload#download_tnr_homologated', as: 'download_tnr_homologated'
  #usuarios
  get '/upload_users', to: 'users#upload_users', as: 'upload_users'
  post '/load_users', to: 'users#load_users', as: 'load_users'
  post '/users/create_user' => 'users#create_user'
  post '/user/toggle/:id', to: 'users#toggle', as: 'toggle_user'
  get '/download/users', to: 'users#download_users', as: 'download_users'
  #clientes
  get '/customers/search', to: 'customers#search', as: 'search_customer'
  get '/clientes', to: 'customers#search_tracking', as: 'search_tracking'
  get '/busqueda', to: 'customers#find_by_rut_and_code', as: 'find_by_rut_and_code'
  #templates
  get '/products/mandatory', to: 'products#template_mandatory', as: 'mandatory_template'
  get '/template/users', to: 'users#template', as: 'users_template'
  get '/products/template',  to: 'products#template_products', as: 'template_products'
  get '/template/discounts', to: 'products#template_discounts', as: 'template_discounts'
  get '/template/stock', to: 'products#template_stock', as: 'template_stock'
  get '/template/comparator', to: 'products#template_comparator', as: 'template_comparator'
  get '/template/addressees', to: 'data_upload#template_addressees', as: 'template_addressees'
  get '/template/tnr_retail', to: 'data_upload#template_tnr_retail', as: 'template_tnr_retail'
  get '/template/oc_retail', to: 'data_upload#template_oc_retail', as: 'template_oc_retail'
  get '/template/cost_center', to: 'data_upload#template_cost_center', as: 'template_cost_center'
  get '/template/miele_roles', to: 'data_upload#template_miele_roles', as: 'template_miele_roles'
  get '/template/commissions', to: 'data_upload#template_commissions', as: 'template_commissions'
  get '/template/project', to: 'data_upload#template_project', as: 'template_project'
  get '/template/project_installation_values', to: 'data_upload#template_project_installation_values', as: 'template_project_installation_values'
  get '/template/project_installation_discounts', to: 'data_upload#template_project_installation_discounts', as: 'template_project_installation_discounts'
  get '/template/dispatch_rules', to: 'data_upload#template_dispatch_rules', as: 'template_dispatch_rules'


  #comparador
  get '/comparator', to: 'comparator#index', as: 'comparator'
  post '/comparator/add/:id', to: 'comparator#add_product', as: 'add_product_comparator'
  post '/comparator/remove/:id', to: 'comparator#remove_product', as: 'remove_product_comparator'
  get '/comparator/empty', to: 'comparator#empty', as: 'empty_comparator'
  get '/comparator/back_and_empty', to: 'comparator#back_and_empty', as: 'back_and_empty_comparator'

  #WebPay 
  post '/webpay/return_url', to: 'webpay#return_url', as: :webpay_return
  post '/webpay/webpay_final_url', to: 'webpay#webpay_final_url', as: :webpay_result
  get 'webpay/success', to: 'webpay#webpay_success', as: :webpay_success
  get '/webpay/error/:id', to: 'webpay#webpay_error', as: :webpay_error
  get '/webpay/nullify/:id', to: 'webpay#webpay_nullify', as: :webpay_nullify
  get '/webpay/already_paid/:id', to: 'webpay#already_paid', as: :already_paid
  get '/webpay/terms_and_conditions/:id', to: 'webpay#terms_and_conditions', as: :terms_and_conditions
  get '/webpay/download_terms', to:'webpay#download_terms', as: :download_terms

  #pago
  resources :payments, only: [:destroy]
  post '/payments/:id/validate_payment', to: 'payments#validate_payment', as: :validate_payment

  #documentos
  resources :billing_documents, only: [:destroy]
  resources :sell_note_documents, only: [:destroy]
  resources :payment_documents, only: [:destroy]
  resources :credit_notes, only: [:destroy]
  resources :backup_documents, only: [:destroy]
  #api
  post '/ecommerce_sales', to: 'ecommerce_sale#create'
  post '/create_ecommerce_quotation', to: 'ecommerce_sale#create_b2c_ecommerce_quotation'
  get '/get_stock', to: 'ecommerce_sale#get_stock'
  post '/discount_stock', to: 'ecommerce_sale#discount_stock'
  post '/reverse_stock', to: 'ecommerce_sale#reverse_stock'

  resources :dispatch_guides, only: :destroy
  resources :dispatch_groups, only: [:update, :destroy, :create]
  resources :unit_real_states, only: [:new, :update, :destroy, :create]
  resources :config_unit_real_states, only: [:create, :update, :destroy]

  get '/unit_real_states/new_show/:quotation_id', to: 'unit_real_states#new_show'
  get '/unit_real_states/new_config_show/:quotation_id', to: 'unit_real_states#new_config_show'
  
  post '/unit_real_states/create_show/', to: 'unit_real_states#create_show'
  patch '/unit_real_states/update_show/:id', to: 'unit_real_states#update_show'
  delete '/unit_real_states/delete_show/:id', to: 'unit_real_states#destroy_show'

  get '/get_current_quantity', to: 'product_in_unit_real_states#get_current_quantity'
  post '/create_or_update', to: 'product_in_unit_real_states#create_or_update'
  delete '/product_in_unit_real_state/:id', to: 'product_in_unit_real_states#destroy'
  get '/get_updated_to_assign_quantity/:id', to: 'quotation_products#get_updated_to_assign_quantity'
  post '/clone_unit', to: 'config_unit_real_states#clone_unit'

  post 'dispatch_groups/:id/change_state/:new_state', to: 'dispatch_groups#change_state', as: :change_dispatch_group_state
  patch 'dispatch_groups/:id/installation', to: 'dispatch_groups#installation', as: :dispatch_group_installation
  post 'dispatch_groups/new/:quotation_id', to: 'dispatch_groups#new', as: :new_dispatch_group
  post 'dispatch_groups/new', to: 'dispatch_groups#new_for_project', as: :new_dispatch_group_project
  post 'dispatch_groups/new_show', to: 'dispatch_groups#new_for_project_show', as: :new_dispatch_group_project_show
  post 'dispatch_groups/delete_dispatch_group_project', to: "dispatch_groups#delete_dispatch_group_project"
  post 'dispatch_groups/delete_dispatch_group_project_show', to: "dispatch_groups#delete_dispatch_group_project_show"
  post 'dispatch_groups/update_dispatch_quantity', to: "dispatch_groups#update_dispatch_quantity"
  post 'dispatch_groups/update_dispatch_quantity_show', to: "dispatch_groups#update_dispatch_quantity_show"
  post 'dispatch_groups/delete_aux', to: "dispatch_groups#delete_aux"
  post 'dispatch_groups/delete_aux_show', to: "dispatch_groups#delete_aux_show"
  patch '/dispatch_groups/update_show/:id', to: 'dispatch_groups#update_show'
  post '/dispatch_groups/create_show', to: 'dispatch_groups#create_show'
  post 'dispatch_groups/:id/validate_by_finance', to: 'dispatch_groups#validate_by_finance', as: :validate_by_finance

  #post '/unit_real_states/new', to: 'unit_real_states#new', as: 'new_unit_real_state'


  get 'leads/add/product_form', to: 'leads#add_product_form', as: :add_product_form_to_lead
  get 'leads/download', to: 'leads#download', as: :download_leads
  get 'leads/:id/to_quotation', to: 'leads#to_quotation', as: :lead_to_quotation
  resources :leads, except: :destroy

  delete 'quotation_products/:id', to: 'quotation_products#destroy', as: :remove_quotation_product
  get 'quotation/:quotation_id/quotation_products/:sku', to: 'quotation_products#check_added_product'
  resources :quotation_products, only: :create
  patch 'quotation_products/:id/update_quantity', to: 'quotation_products#update_quantity'
  patch 'quotation_products/:id/update_price', to: 'quotation_products#update_price'

  #API ROUTES
  namespace :api do
    namespace :v1, defaults: {format: :json} do
      #DISPATCH GROUP
      post 'dispatch_groups/:id/close', to: "dispatch_groups#close_dispatch_group"

      # DETAIL_QUOTATION_PRODUCTS
      patch 'detail_quotation_products/update_state', to: "detail_quotation_products#update_state"
      
      # CUSTOMER
      get 'customers/get_quotations', to: "customers#get_customer_quotations"
      post 'customers', to: "customers#create_or_update"

      # Quotation current status
      get 'quotations/:id/current_status', to: 'quotations#get_current_status'

      # TEST
      get 'tests/prueba', to: "tests#prueba"
    end
  end
end
