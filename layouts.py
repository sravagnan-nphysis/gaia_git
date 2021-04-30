"""
This module contains the components for the layout of the Dash app.
Author: Stefano Ravagnan <stefano.ravagnan@nphysis.com>
"""
import dash_bootstrap_components as dbc
import dash_html_components as html
import dash_core_components as dcc

days_buttons = dbc.Row(
    [
        dbc.Col(
            dbc.ButtonGroup(
                [
                    dbc.Button(
                        id="first_date",
                        className="button",
                    ),
                    dbc.Button(
                        id="second_date",
                        className="button",
                    ),
                    dbc.Button(
                        id="third_date",
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

tab_style = {
    "text-transform": "uppercase",
    "border": "grey",
    "font-size": "11px",
    "font-weight": 600,
    "align-items": "center",
    "justify-content": "center",
    "border-radius": "4px",
    "padding": "6px",
}

tab_selected_style = {
    "text-transform": "uppercase",
    "font-size": "11px",
    "font-weight": 600,
    "align-items": "center",
    "justify-content": "center",
    "border-radius": "4px",
    "padding": "6px",
}

card_tab = (
    dbc.Card(
        [
            dbc.CardHeader(
                dcc.Tabs(
                    [
                        dcc.Tab(
                            label="MATTINA",
                            value="morning_tab",
                            className="custom-tab",
                            style=tab_style,
                            selected_style=tab_selected_style,
                        ),
                        dcc.Tab(
                            label="POMERIGGIO",
                            value="afternoon_tab",
                            className="custom-tab",
                            style=tab_style,
                            selected_style=tab_selected_style,
                        ),
                    ],
                    id="card-tabs",
                    value="morning_tab",
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
                                                html.A(" Biv. Ferrino"),
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
                                                id="weather_icon",
                                                height="75",
                                            ),
                                        ),
                                        dbc.Col(
                                            html.Div(
                                                html.A(
                                                    dbc.Button(
                                                        id="comfort",
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
                                                        id="temperature",
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
                                                        id="wind-speed",
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
                                                        id="wind-direction",
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
