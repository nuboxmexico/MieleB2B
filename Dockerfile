# Etapa de construcción
ARG RUBY_VERSION=2.6.10

FROM ruby:${RUBY_VERSION}

USER root

# Instalación de dependencias del sistema necesarias
RUN apt-get update && apt-get install -y \
    wkhtmltopdf \
    qt5-qmake \
    libqwt-qt5-6 \
    g++ libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x \
    curl \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Instalar bundler
RUN gem install bundler -v 2.4.22

# Copiar los archivos Gemfile y Gemfile.lock
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./

# Instalar dependencias de Ruby
RUN bundle install --jobs=4 --retry=3

# Copiar el resto del código
COPY . .

# Exponer el puerto para Rails
EXPOSE 3000

# Comando para ejecutar el servidor Rails
CMD ["rails", "server", "-b", "0.0.0.0"]

#EJECUTAR ESTO DE FORMA MANUAL AL CORRER CON DOCKER BUILD
# sudo docker cp config/version 214e35979ae1:/usr/src/app/config/version
#touch config/version

