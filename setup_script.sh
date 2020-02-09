#!/bin/bash

# Intended for ubuntu 18.04
# Setup script to install environment, and user to run and host site

# Vars to keep track
REPO_NAME=django-website
WEB_NAME=djangowebsite
WEB_ROOT=/web/$REPO_NAME
USER=webling
GROUP=web
DOMAIN=slothbox.vip

# Install needed reqired libs for ubuntu
sudo apt-get update && sudo apt-get upgrade -y
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get install -y python3-venv python3-dev python3-pip nginx supervisor python-certbot-nginx

# Create user and group to run and own website without login rights
sudo useradd -M $USER
sudo usermod -L $USER
sudo groupadd $GROUP
sudo usermod -a -G $USER $GROUP

# Run install of python venv and requirements
python3 -m venv $WEB_ROOT/venv
. $WEB_ROOT/venv/bin/activate
pip install -r $WEB_ROOT/requirements.txt

# Set up DB
python manage.py makemigrations
python manage.py migrate
python loaddata fixtures

# Have user own site
sudo chown -R $USER $WEB_ROOT

# Setup supervisord
sudo cp $WEB_ROOT/supervisor/$WEB_NAME.conf /etc/supervisor/conf.d/$WEB_NAME.conf
sudo mkdir -p $WEB_ROOT/logs/
sudo touch $WEB_ROOT/logs/supervisor.log
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart $WEB_NAME

# Setup nginx
sudo cp $WEB_ROOT/nginx/$WEB_NAME /etc/nginx/sites-available/$WEB_NAME
sudo ln -s /etc/nginx/sites-available/$WEB_NAME /etc/nginx/sites-enabled/$WEB_NAME
sudo rm /etc/nginx/sites-enabled/default
sudo service nginx restart

# Setup certrs for HTTPS traffic
sudo certbot --nginx -d $DOMAIN -m seanjones2848@gmail.com --agree-tos -n --redirect

