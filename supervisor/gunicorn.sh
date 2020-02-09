#!/bin/bash

NAME="django-website"                                       # Name of the application
DJANGODIR=/web/django-website                               # Django project directory
SOCKFILE=/web/django-website/run/gunicorn.sock              # Communiction socket
USER=webling                                                # Dedicated django user
GROUP=web                                                   # The group to run as
NUM_WORKERS=3                                               # How many processes Gunicorn should spawn (2*CPUs+1)
DJANGO_SETTINGS_MODULE=django-website.settings              # Which settings to use
DJANGO_WSGI_MODULE=django-website.wsgi                      # WSGI module name

echo "Starting $NAME as `whoami`"

# Activate virtual env
cd $DJANGODIR
. ./venv/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Create run directory if it doesn't exist yet
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start up Gunicorn
exec gunicorn ${DJANGO_WSGI_MODULE}:application \
    --name $NAME \
    --workers $NUM_WORKERS \
    --bind=unix:$SOCKFILE \
    --log-level=debug \
    --log-file=-
