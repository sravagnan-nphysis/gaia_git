"""
This module contains the Dash app initialisation and the entrypoint for running it.
Author: Stefano Ravagnan <stefano.ravagnan@nphysis.com>
"""
import dash
import dash_bootstrap_components as dbc
import dash_core_components as dcc

from callbacks import register_callbacks
from layouts import deck

FA = "https://use.fontawesome.com/releases/v5.12.1/css/all.css"
Mandatory = "http://fonts.cdnfonts.com/css/mandatory-plaything"

app = dash.Dash(
    "weather_widget",
    title="nPhysis Widget",
    external_stylesheets=[dbc.themes.COSMO, FA, Mandatory],
)

server = app.server

app.layout = dbc.Container(
    id="page-container",
    children=[deck] + [dcc.Interval(id="update", interval=60 * 1000, n_intervals=0)],
    className="mx-auto",
    style={"max-width": "400px", "textAlign": "center"},
)

register_callbacks(app)

if __name__ == "__main__":
    app.run_server(host="127.0.0.1", port="8050", debug=True)
