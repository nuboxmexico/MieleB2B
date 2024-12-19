Apipie.configure do |config|
  config.app_name                = "Miele"
  config.api_base_url            = ""
  config.doc_base_url            = "/docs/api"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/ecommerce_sale_controller.rb"
  config.languages               = ["es"]
  config.default_locale          = "es"
  config.app_info = "Para realizar request a través de la API debes agregar en los headers de tu aplicación los siguientes parámetros:
  'User-Email' : El Email asociado a la tienda en la plataforma 
  'User-Token' : El token proporcionado por Miele"
end
