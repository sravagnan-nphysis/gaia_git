"""
This module contains the components for the layout of the Dash app.
Author: Piero Ferrarese <piero.ferrarese@nphysis.com>
"""
import dash_bootstrap_components as dbc
import dash_html_components as html

header = dbc.Navbar(
    children=[
        html.A(
            dbc.Row(
                [
                    dbc.Col(
                        html.Img(
                            src="https://www.meteoski.it/assets/site/img/logo2.png",
                            height="30px",
                        )
                    ),
                    dbc.Col(dbc.NavbarBrand("Meteoski", className="ml-2")),
                ],
                align="center",
                no_gutters=True,
            ),
            href="https://www.meteoski.it",
        ),
        dbc.Button(html.H2("<"), id="previous-time", className="mx-auto"),
        html.Div([html.H3(id="date"), html.H5(id="daytime")], className="mx-auto"),
        dbc.Button(html.H2(">"), id="next-time", className="mx-auto"),
    ],
    id="navbar",
)

grid = [
    dbc.Row(
        children=[
            dbc.Col(
                dbc.Card(
                    children=[
                        dbc.CardHeader("Weather Summary"),
                        html.Img(
                            id="weather-summary",
                            className="mx-auto",
                            style={"width": "17%", "height": "17%"},
                        ),
                    ],
                    id="weather-summary-card",
                ),
                id="weather-summary-col",
            ),
            dbc.Col(
                dbc.Card(
                    children=[
                        dbc.CardHeader("Wind Speed"),
                        html.H2(id="wind-speed", className="mx-auto"),
                    ],
                    id="wind-speed-card",
                ),
                id="wind-speed-col",
            ),
        ],
        id="first-row",
    ),
    dbc.Row(
        children=[
            dbc.Col(
                dbc.Card(
                    children=[
                        dbc.CardHeader("Temperature"),
                        html.H2(id="temperature", className="mx-auto"),
                    ],
                    id="temperature-card",
                ),
                id="temperature-col",
            ),
            dbc.Col(
                dbc.Card(
                    children=[
                        dbc.CardHeader("Wind Direction"),
                        html.H2(id="wind-direction", className="mx-auto"),
                    ],
                    id="wind-direction-card",
                ),
                id="wind-direction-col",
            ),
        ],
        id="second-row",
    ),
]
