from datetime import datetime

import pandas as pd
import dash
from dash.dependencies import Output, Input, State
import dash_bootstrap_components as dbc
import dash_core_components as dcc
import dash_html_components as html
from dash.exceptions import PreventUpdate

import api
from components import grid, header
from settings import DAYTIMES, degrees_to_cardinal


app = dash.Dash('weather_widget',
                external_stylesheets=[dbc.themes.CYBORG])

server = app.server

app.layout = dbc.Container(id='page-container',
                           children=[header] + grid + 
                                     [dcc.Interval(id='update', interval=60*1000, n_intervals=0)], 
                           className="p-5",
)


@app.callback([Output("date", "children"),
               Output("daytime", "children"),
               Output('weather-summary', 'src'),
               Output('wind-speed', "children"),
               Output("wind-direction", "children"),
               Output("temperature", "children")],
              [Input('update', 'n_intervals'),
               Input("previous-time", 'n_clicks'),
               Input("next-time", "n_clicks")
              ],
              [State("date", "children"),
               State("daytime", "children")
              ]
              )
def update_widget(interval, previous, after, current_date, current_time):
    token = api.get_token()
    data = pd.DataFrame(api.get_data(token))
    all_keys = list(data.iloc[0]['Overviews'].keys())
    cols = ["Data", "Idloc", "Temperatura", "IntensitaVento",
            "DirezioneVento", "ComfortAssoluto", "Colore", "EtichettaGiorno"]
    data[all_keys] = data['Overviews'].apply(lambda x: pd.Series(x))
    ctx = dash.callback_context

    if not ctx.triggered:
        button_id = 'No clicks'
    else:
        button_id = ctx.triggered[0]['prop_id'].split('.')[0]
    if button_id=='No clicks':
        daytimes = pd.DataFrame(DAYTIMES, columns=['label', 'beginning', 'end'])
        hour = pd.Timestamp.today().hour
        
        day_label = daytimes.loc[(daytimes['beginning'] <= hour) & \
                                 (daytimes['end'] > hour),'label'].values[0]
        date = str(pd.Timestamp.today())[:10]
        
        subset = data.loc[(data['Idloc']==data['Idloc'].unique()[0]) & \
                          (data['Data']==date) &\
                          (data['EtichettaGiorno']==day_label), cols]
    elif button_id=='previous-time' or button_id=='next-time':
        date = pd.to_datetime(current_date)
        if current_time=='Mattina':
            day_label = 'Pomeriggio'
            if button_id=='previous-time':
                date -= pd.DateOffset(1)
        elif current_time=='Pomeriggio':
            day_label = 'Mattina'
            if button_id=='next-time':
                date += pd.DateOffset(1)
        date = str(date)[:10]
        subset = data.loc[(data['Idloc']==data['Idloc'].unique()[0]) & \
                          (data['Data']==date) &\
                          (data['EtichettaGiorno']==day_label), cols]
                
    if subset.shape[0]==1:
        img_url = "https://www.meteoski.it/assets/site/img/tag_{}.png".\
            format(subset['Colore'].values[0].lower())
        
    
        return [date,
                day_label,
                img_url,
                "{:.2f} km/h".format(subset['IntensitaVento'].values[0]),
                degrees_to_cardinal(subset['DirezioneVento'].values[0]),
                '{:.2f} \N{DEGREE SIGN}'.format(subset['Temperatura'].values[0])]
    else:
        print("No update: subset shape {}".format(subset.shape))
        raise PreventUpdate

                
if __name__=='__main__':
    app.run_server(host='127.0.0.1', port='8050', debug=True)
