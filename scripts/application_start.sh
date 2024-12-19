#!/bin/bash
echo "Running application_start hook"
# Source RVM
source ~/.rvm/bin/rvm
cd /var/www/html/miele/current
# Set folder permissions
rvm use 2.6.10
sudo chown -R www-data:www-data /var/www/html/miele/current
sudo chown -R ubuntu:ubuntu /var/www/html/miele/current
sudo chmod -R 755 /var/www/html/miele/current
sudo chown -R ubuntu:ubuntu /var/www/html/miele/current/log
sudo chmod -R 750 /var/www/html/miele/current/log
sudo chown -R ubuntu:ubuntu /var/www/html/miele/current/tmp
sudo chmod -R 770 /var/www/html/miele/current/tmp
sudo chown -R ubuntu:ubuntu /var/www/html/miele/current/public/uploads
sudo chmod -R 750 /var/www/html/miele/current/public/uploads
sudo chown -R ubuntu:ubuntu /var/www/html/miele/current/.bundle
sudo chmod -R 755 /var/www/html/miele/current/.bundle
# bundle
bundle install --deployment --without development test
bundle exec rake assets:precompile RAILS_ENV=$DEPLOYMENT_GROUP_NAME
if [ "$DEPLOYMENT_GROUP_NAME" == "production" ]
then
    bundle exec rake assets:sync RAILS_ENV=$DEPLOYMENT_GROUP_NAME # Synchronize assets using asset_sync
fi
bundle exec rake db:migrate RAILS_ENV=$DEPLOYMENT_GROUP_NAME
if [ "$DEPLOYMENT_GROUP_NAME" == "production" ] 
then
    sudo service nginx reload
else
    sudo service apache2 restart
fi



