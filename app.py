"""
This module contains the Dash app initialisation and the entrypoint for running it.
Author: Piero Ferrarese <piero.ferrarese@nphysis.com>
"""
import dash
import dash_bootstrap_components as dbc
import dash_core_components as dcc

from callbacks import register_callbacks
from layouts import grid, header

app = dash.Dash(
    "weather_widget", title="nPhysis Widget", external_stylesheets=[dbc.themes.CYBORG]
)

server = app.server

app.layout = dbc.Container(
    id="page-container",
    children=[header]
    + grid
    + [dcc.Interval(id="update", interval=60 * 1000, n_intervals=0)],
    className="p-5",
)

register_callbacks(app)


if __name__ == "__main__":
    app.run_server(host="127.0.0.1", port="8050", debug=True)
