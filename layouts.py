"""
This module contains the components for the layout of the Dash app.
Author: Piero Ferrarese <piero.ferrarese@nphysis.com>
"""
import dash_bootstrap_components as dbc
import dash_html_components as html

"""
This module contains the components for the layout of the Dash app.
Author: Piero Ferrarese <piero.ferrarese@nphysis.com>
"""
import dash_bootstrap_components as dbc
import dash_html_components as html

# header = dbc.Navbar(
#     children=[
#         html.A(
#             dbc.Row(
#                 [
#                     dbc.Col(
#                         html.Img(
#                             src="https://www.meteoski.it/assets/site/img/logo2.png",
#                             height="30px",
#                         )
#                     ),
#                     dbc.Col(dbc.NavbarBrand("Meteoski", className="ml-2")),
#                 ],
#                 align="center",
#                 no_gutters=True,
#             ),
#             href="https://www.meteoski.it",
#         ),
#         dbc.Button(html.H2("<"), id="previous-time", className="mx-auto"),
#         html.Div([html.H3(id="date"), html.H5(id="daytime")], className="mx-auto"),
#         dbc.Button(html.H2(">"), id="next-time", className="mx-auto"),
#     ],
#     id="navbar",
# )

# grid = [
#     dbc.Row(
#         children=[
#             dbc.Col(
#                 dbc.Card(
#                     children=[
#                         dbc.CardHeader("Weather Summary"),
#                         html.Img(
#                             id="weather-summary",
#                             className="mx-auto",
#                             style={"width": "17%", "height": "17%"},
#                         ),
#                     ],
#                     id="weather-summary-card",
#                 ),
#                 id="weather-summary-col",
#             ),
#             dbc.Col(
#                 dbc.Card(
#                     children=[
#                         dbc.CardHeader("Wind Speed"),
#                         html.H2(id="wind-speed", className="mx-auto"),
#                     ],
#                     id="wind-speed-card",
#                 ),
#                 id="wind-speed-col",
#             ),
#         ],
#         id="first-row",
#     ),
#     dbc.Row(
#         children=[
#             dbc.Col(
#                 dbc.Card(
#                     children=[
#                         dbc.CardHeader("Temperature"),
#                         html.H2(id="temperature", className="mx-auto"),
#                     ],
#                     id="temperature-card",
#                 ),
#                 id="temperature-col",
#             ),
#             dbc.Col(
#                 dbc.Card(
#                     children=[
#                         dbc.CardHeader("Wind Direction"),
#                         html.H2(id="wind-direction", className="mx-auto"),
#                     ],
#                     id="wind-direction-card",
#                 ),
#                 id="wind-direction-col",
#             ),
#         ],
#         id="second-row",
#     ),
# ]

# navbar = dbc.Navbar(
#     [
#         html.A
#         (
#             dbc.Row
#             (
#                 [
#                     dbc.Col
#                     (
#                         html.Img
#                         (
#                             src="https://www.meteoski.it/assets/site/img/logo_white.png",
#                             height="30px",
#                         )
#                     ),
#                 ],
#                 align="center",
#                 no_gutters=True,
#             ),
#         ),
#         dbc.NavbarToggler(id="navbar-toggler"),
#         dbc.Collapse(days_buttons, id="navbar-collapse", navbar=True),
#     ],
#     color="#325c90",
#     dark=True,
# )

"""
Author: Stefano Ravagnan <stefano.ravagnan@nphysis.com>
"""

days_buttons = dbc.Row(
    [
        dbc.Col(
            dbc.ButtonGroup(
                [
                    dbc.Button(
                        "Mar",
                        className="button",
                        id="first_button_group",
                    ),
                    dbc.Button(
                        "Mer",
                        id="middle_button_group",
                        className="button",
                    ),
                    dbc.Button(
                        "Gio",
                        id="last_button_group",
                        className="button",
                    ),
                ],
                className="button_group",
            ),
        ),
    ],
    no_gutters=True,
    className="ml-auto flex-nowrap mt-3 mt-md-0",
    align="center",
)

card_tab = (
    dbc.Card(
        [
            dbc.CardHeader(
                dbc.Tabs(
                    [
                        dbc.Tab(
                            label="MATTINA",
                            tab_id="morning_tab",
                            tab_style={"margin": "auto", "font-size": "13px"},
                            label_style={"color": "#325c90"},
                        ),
                        dbc.Tab(
                            label="POMERIGGIO",
                            tab_id="afternoon_tab",
                            tab_style={"margin": "auto", "font-size": "13px"},
                            label_style={"color": "#325c90"},
                        ),
                    ],
                    id="card-tabs",
                    card=True,
                    active_tab="active_tab",
                ),
                className="deck_card_header",
            ),
            dbc.CardBody(
                [
                    html.Img(
                        src="https://nphysis.com/wp-content/uploads/2021/02/geochip-marmolada-diventa-accessibile-digitalmente.jpg",
                        style={
                            "width": "100%",
                            "height": "100%",
                            "opacity": "20%",
                            "margin": "0px",
                            "padding": "0px",
                        },
                    ),
                    dbc.CardImgOverlay(
                        [
                            html.Div(
                                dbc.Row(
                                    [
                                        dbc.Col(
                                            [
                                                html.I(
                                                    className="fas fa-map-marker-alt fa-lg"
                                                ),
                                                html.A(" Bivacco Ferrario"),
                                            ],
                                            style={"textAlign": "center"},
                                        ),
                                    ],
                                    style={
                                        "max-width": "100%",
                                        "margin": "auto",
                                        "padding-bottom": "15px",
                                    },
                                ),
                            ),
                            html.Div(
                                dbc.Row(
                                    [
                                        dbc.Col(
                                            html.Img(
                                                src="https://www.meteoski.it/images/ms2.png",
                                                id="weather_icon_image",
                                            ),
                                            style={"margin": "auto"},
                                        ),
                                        dbc.Col(
                                            html.Div(
                                                html.A(
                                                    dbc.Button(
                                                        "76%",
                                                        className="round-button",
                                                        style={"margin": "auto"},
                                                    ),
                                                    href="https://www.meteoski.it/info/indici-di-comfort",
                                                ),
                                            ),
                                            style={"margin": "auto"},
                                        ),
                                    ]
                                ),
                                style={
                                    "max-width": "75%",
                                    "margin": "auto",
                                },
                            ),
                            html.Div(
                                dbc.Row(
                                    [
                                        dbc.Col(
                                            html.Div(
                                                [
                                                    html.I(
                                                        className="fa fa-thermometer-half mx-auto fa-lg"
                                                    ),
                                                    html.H6(
                                                        "-3°",
                                                        style={
                                                            "margin-top": "0.2rem",
                                                            "margin-left": "0.5rem",
                                                        },
                                                    ),
                                                ]
                                            ),
                                            style={
                                                "border-right": "1.5px solid grey",
                                                "padding": "0px",
                                            },
                                        ),
                                        dbc.Col(
                                            html.Div(
                                                [
                                                    html.I(
                                                        className="fa fa-wind mx-auto fa-lg"
                                                    ),
                                                    html.H6(
                                                        "7 km/h",
                                                        style={"margin-top": "0.2rem"},
                                                    ),
                                                ]
                                            ),
                                            style={
                                                "border-right": "1.5px solid grey",
                                                "padding": "0px",
                                            },
                                        ),
                                        dbc.Col(
                                            html.Div(
                                                [
                                                    html.I(
                                                        className="fa fa-location-arrow mx-auto fa-lg"
                                                    ),
                                                    html.H6(
                                                        "SSE",
                                                        style={"margin-top": "0.2rem"},
                                                    ),
                                                ]
                                            ),
                                            style={"padding": "0px"},
                                        ),
                                    ]
                                ),
                                style={
                                    "textAlign": "center",
                                    "padding-bottom": "150px",
                                    "padding-top": "15px",
                                },
                            ),
                        ],
                        className="card_overlay",
                    ),
                ],
                className="deck_card_body",
            ),
            dbc.CardFooter(
                [
                    dbc.Row(
                        [
                            dbc.Col(
                                html.A(
                                    html.Img(
                                        src="https://www.meteoski.it/assets/site/img/logo_blue.png",
                                        className="logo",
                                    ),
                                    style={"textAlign": "left", "margin": "0px"},
                                    href="https://www.meteoski.it",
                                ),
                            ),
                            dbc.Col([days_buttons], style={"textAlign": "right"}),
                        ],
                    )
                ],
                className="deck_card_footer",
            ),
        ],
        className="deck_card",
    ),
)

row_1 = dbc.Row(
    [
        dbc.Col(dbc.Card(card_tab)),
    ],
    className="mb-4",
)

deck = html.Div(
    dbc.Card([dbc.CardBody([row_1])]),
    style={"margin": "auto"},
)
