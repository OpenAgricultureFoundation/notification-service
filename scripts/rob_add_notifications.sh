#!/bin/bash

# Get the path to parent directory of this script.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
cd $DIR # Go to the project top level dir.

# Deactivate any current python virtual environment we may be running.
if ! [ -z "${VIRTUAL_ENV}" ] ; then
    echo "deactivate"
fi

# All DEPLOYED env vars live in app.yaml for the gcloud GAE deployed app.
# Since we are running locally, we have to set our env. vars.
if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS}" ]]; then
  # gcloud_env.bash has not been sourced, so do it now
  source $DIR/config/gcloud_env.bash
fi

# Has the user setup the local python environment we need?
if ! [ -d pyenv ]; then
  echo 'ERROR: you have not run ./scripts/local_development_one_time_setup.sh'
  exit 1
fi

# Yes, so activate it for this bash process
source pyenv/bin/activate

# Add the top leve dir to the py path so we can pick up the submodule.
export PYTHONPATH=$DIR

# Locally create a recipe start message, then parse it and update datastore.

python3.6 -c "from cloud_common.cc.notifications.notification_messaging import NotificationMessaging
import cloud_common.cc.notifications.scheduler as scheduler
import logging
import datetime as dt
logging.basicConfig(level=logging.DEBUG)

devID='EDU-39BD6A22-c4-b3-01-8d-9b-8c'

nm = NotificationMessaging()
message = {
'device_ID': devID,
'message_type': 'recipe_start',
'message': 'robs hack'
}
nm.parse(message)

sched = scheduler.Scheduler()

print(f'\n\nTime now UTC={dt.datetime.utcnow()}')

print('\ncheck:')
sched.check(devID)

print('\nbump hours to 49:')
sched.set_testing_hours(49)
sched.check(devID)


"

