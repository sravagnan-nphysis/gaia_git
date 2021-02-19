.. Meteoski Weather Widget
Deployment
===========================
For Deployment to `Heroku <www.heroku.com>`_, follow the Dash `guide <www.heroku.com>`_.
Of course, the app name here below exists already, and it would be just matter of updating it.

At the command line::
  
     heroku create nphysis-weather-widget # change my-dash-app to a unique name
     git add . # add all files to git
     git commit -m 'Initial app boilerplate'
     git push heroku master # deploy code to heroku
     heroku ps:scale web=1  # run the app with a 1 heroku "dyno"


 
