.. Meteoski Weather Widget
Installation
===========================
In order to run locally the widget.
At the command line::
     
       python -m venv weather_widget  
       source weather_widget/bin/activate
       pip install -r requirements
       python app.py

To execute linters, and tests::
  
       pylint .
       black .
       isort api.py app.py callbacks.py layouts.py settings.py

   

