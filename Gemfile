source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2.1'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'execjs'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
#gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'awesome_print' , '2.0.0.pre2'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'
gem 'mimemagic', github: 'mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f'
#gem 'mimemagic', '0.3.0', path: 'lib/mimemagicshit'
# Iconos svg 
gem 'font-awesome-sass'

# Generación de PDF's
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Framework front-end bootstrap
gem 'bootstrap-sass', '~> 3.4.1'
#Buscador en los select box
# Paginación con estilo de boostrap
gem 'will_paginate-bootstrap'
# Sweet alert 
gem 'rails-assets-sweetalert2', '~> 5.1.1', source: 'https://rails-assets.org'
gem 'sweet-alert2-rails', '~> 0.1.0'


#Email

gem 'mandrill-api', require:'mandrill'


source 'https://rails-assets.org/' do
  # Framework front-end basado en Bootstrap 
  gem 'rails-assets-adminlte', '~> 2.3.11'
end

# validador para formularios en bootstrap
gem 'bootstrap_validator_rails', '~> 1.1'
gem 'bootstrap3-datetimepicker-rails', '~> 4.14.30'
gem 'momentjs-rails'
# Capistrano para despliegue de aplicación en servidor remoto
gem 'capistrano'
gem 'capistrano-rvm'
gem 'capistrano-ssh-doctor'
gem 'capistrano-bundler'
gem 'net-ssh'
gem 'net-scp'
gem 'sshkit'
gem 'airbrussh'
gem 'coderay'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Autenticación de usuarios
gem 'devise'
gem 'devise-i18n'

# Paginación con estilo de boostrap
gem 'will_paginate-bootstrap'

# Cargado de pagina con estilo de pace
gem 'pace-rails'

#Gema para las notificaciones tipo toast
gem 'toastr-rails'

# Notificador de errores vía email (u otras opciones)
gem 'exception_notification'

#Gema para leer archivos Excel y CSV
gem 'roo'

# Cron jobs
gem 'whenever'

# Conexiones REST
gem 'faraday'

# Authorization
gem 'cancancan'

# traducción de activerecord
gem 'rails-i18n', '~> 5.1'

#conexión SOAP
gem 'savon', '~> 2.11.1'

# Procesamiento de imágenes
gem "paperclip", "~> 6.0.0"

## descarga de excel
gem 'caxlsx_rails'

## feriados
gem 'holidays'
gem 'business_time'

# Para la generación de codigos de barra
#gem 'barby'
#gem 'chunky_png'

# traducción de activerecord
gem 'rails-i18n', '~> 5.1'

# registra cambios en los registro de la db
gem 'paper_trail'

gem 'signer', '~> 1.4.2'

# DDOS
gem 'rack-attack'


# documentación API (descomentar solo si es necesario publicar una API)
gem 'apipie-rails'
# autenticación para APIS (descomentar solo si es necesario)
gem 'simple_token_authentication'

# interfaz para hacer mensajes de error más facil
gem 'gaffe'

# editor de texto enriquecido
gem 'tinymce-rails'
gem 'tinymce-rails-langs'

# soft delete
gem 'acts_as_paranoid'

## Gema de amazon para hacer conexión con S3 en la subida de imágenes
gem 'aws-sdk'
gem 'aws-sdk-s3'

# assets en cloudfront
gem 'fog-aws'
gem 'asset_sync'

#formularios anidados
gem "cocoon"

# exportación de datos a través de semillas Rails
gem 'seed_dump'

# easy sorting and search form
gem 'ransack'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  
  # Variables de entorno en development
  gem 'dotenv-rails'

  # Testing
  gem 'rspec-rails', '~> 3.7'
  gem "capybara"
  gem 'rspec-json_expectations'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'factory_bot_rails', require: false
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'capybara-webkit'
  gem 'database_cleaner'
  
  gem 'rack_session_access'

  # Análisis estático para detección de vulnerabilidades de seguridad (fuente: https://github.com/presidentbeef/brakeman)
  gem 'brakeman', require: false

  # Análisis de cobertura de test
  gem 'simplecov', require: false

  # Code quality reporter
  gem "rubycritic", require: false

  # Trigger Rubycritic each a time file is saved
  gem "guard-rubycritic", require: false
  
  #Time travel and time freezing gem
  gem 'timecop'

  #faker data
  gem 'faker'

end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  ## Mejores erroes en develop
  gem 'better_errors'
  gem 'binding_of_caller'
  #gem 'quiet_assets'  
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'awesome_print' , '2.0.0.pre2'



