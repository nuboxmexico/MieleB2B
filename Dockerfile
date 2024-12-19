ARG RUBY_VERSION=2.6.10

############################################
# builder stage
############################################

FROM ruby:${RUBY_VERSION}

USER root

############################################
# this section could be different for each project
RUN apt-get update && apt-get install -y \
    wkhtmltopdf \
    qt5-qmake \
    libqwt-qt5-6 \ 
    g++ libqt5webkit5-dev gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-x \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update
RUN apt-get install -y nodejs
# Update bundler
#RUN gem update --system 3.2.34
RUN gem install bundler -v 2.4.22
############################################

############################################
# Developement dependencies stage
############################################

COPY Gemfile Gemfile.lock ./
RUN bundle config set without ''
RUN bundle config set with development test
RUN git config --global url."https://".insteadOf git://
RUN bundle install --jobs=4 --retry=3

# ############################################
# ## Development stage
# ############################################

WORKDIR /usr/src

# Copy project code
COPY . .
