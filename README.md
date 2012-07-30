toggl-reports
=============

Set these environment variables:

    TOGGL_API_KEY
    TIMESHEET_USERNAME
    TIMESHEET_PASSWORD

Heroku:

    heroku config:add TOGGLE_API_KEY=<KEY> TIMESHEET_USERNAME=<USERNAME> TIMESHEET_PASSWORD=<PASSWORD>

Shell:

    export TOGGLE_API_KEY=<KEY>
    export TIMESHEET_USERNAME=<USERNAME>
    export TIMESHEET_PASSWORD=<PASSWORD>


Set up Heroku:

https://devcenter.heroku.com/articles/rails3

    # add public hey to heroku
    heroku keys:add ~/.ssh/id_rsa.pub

    # clone existing heroku app
    heroku git:clone -a afternoon-wind-7220
