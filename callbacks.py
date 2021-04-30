"""
This module contains the callbacks implementing the dynamical logic 
of the webapp.

TODO change the color button based on the comfort index values:
     green: #84BD00 --> comfort index >= 0.7
     yellow: #EFC050 --> 0.36 < comfort index > 0.69
     red: #FF6F61 --> comfort index <= 0.35

TODO keep in memory the tab input in order to properly refresh the data in the widget

Author: Stefano Ravagnan <stefano.ravagnan@nphysis.com>
"""
from datetime import datetime
from typing import Tuple

import dash
import dash_html_components as html
import pandas as pd
from dash.dependencies import Input, Output, State
from dash.exceptions import PreventUpdate

import api
import settings
from utils import degrees_to_cardinal, render_content


def register_callbacks(app: dash.Dash) -> None:
    """
    This function register the callbacks to an instanced Dash app.

    Parameters
    ----------
    app: dash.Dash
         An instanciated Dash app
    Returns
    -------
    """

    @app.callback(
        [
            Output("first_date", "children"),
            Output("second_date", "children"),
            Output("third_date", "children"),
            Output("comfort", "children"),
            Output("wind-speed", "children"),
            Output("wind-direction", "children"),
            Output("temperature", "children"),
            Output("weather_icon", "src"),
        ],
        [
            Input("update", "n_intervals"),
            Input("first_date", "n_clicks"),
            Input("second_date", "n_clicks"),
            Input("third_date", "n_clicks"),
            Input("card-tabs", "value"),
        ],
        [
            State("card-tabs", "value"),
        ],
    )
    def update_widget(
        interval: int,
        first_date: int,
        second_date: int,
        third_date: int,
        card_tabs: str,
        card_tabs_state: str,
    ) -> Tuple[str, str, str, float, float, str, float, str]:
        """
        This function updates the widget every interval time set, depending on user inputs,
        which are either browsing to previous or next time instant.
        The function first gets the token, then query the data and filter them according
        the requested input.
        Depending on what triggered the callback, the current date/daytime is changed, depending
        on what was last exposed.
        When it is called at page loading, it displays current date/time.

        Parameters:
        -----------
        interval : int
                        A counter of the number of intervals passed from the startup of the app
        first_date : int
                        A counter of the number of n_clicks the first_date button has been clicked
        second_date : int
                        A counter of the number of n_clicks the second_date button has been clicked
        third_date : str
                        A counter of the number of n_clicks the third_date button has been clicked
        card_tabs : str
                        The content of the tabs div - a string with the label of the day
        first_date_state : str
                    ...

        Returns:
        --------
        first_date : str
                        The label displayed on the first_date button --> e.g. "FRI" or "MON" or "SAT"
        second_date : str
                        The label displayed on the second_date button
        third_date : str
                        The label displayed on the third_date button

        comfort : foat
                        The value of Meteoski's comfort index

        wind_speed : foat
                        The value of Meteoski's wind speed

        wind_direction : str
                        The value of Meteoski's wind direction in str --> e.g. "N" or "NNE" or "SE"

        temperature : foat
                        The value of Meteoski's temperature

        weather_icon : str
                        The url to get the Meteoski's weather icon

        Raises
        ------
        PreventUpdate
               If for some reasons the API does not return anything, or the filtered
               data is empty, the widget will not update.

        Warnings
        --------
        The current datetime is the server one. :todo: update with client datetime.
        The location presented is the first appearing in the queried data. :todo: get as input from url query params.
        """
        token = api.get_token()
        data = pd.DataFrame.from_dict(api.get_data(token))
        all_keys = list(data.iloc[0]["Overviews"].keys())
        cols = [
            "Data",
            "Idloc",
            "Temperatura",
            "IntensitaVento",
            "DirezioneVento",
            "ComfortAssoluto",
            "Colore",
            "EtichettaGiorno",
            "CodiceMeteo",
        ]
        data[all_keys] = data["Overviews"].apply(lambda x: pd.Series(x))

        """
        weather_icons dataframe
        """
        weather_icons = api.get_weather_icons()

        """
        get the current day_label
        """
        daytimes = pd.DataFrame(
            settings.DAYTIMES, columns=["label", "beginning", "end"]
        )
        hour = pd.Timestamp.today().hour
        day_label = daytimes.loc[
            (daytimes["beginning"] <= hour) & (daytimes["end"] > hour), "label"
        ].values[0]

        """
        date buttons
        """
        first_date = pd.Timestamp.today()
        second_date = pd.Timestamp.today() + pd.Timedelta("1 days")
        third_date = pd.Timestamp.today() + pd.Timedelta("2 days")

        """
        subset filtered by constraints
        """
        ctx = dash.callback_context
        if not ctx.triggered:
            button_id = "No clicks"

            if day_label == "Mattina":
                card_tabs = "morning_tab"

            elif day_label == "Pomeriggio":
                card_tabs = "afternoon_tab"

            subset = render_content(card_tabs, "first_date", cols, data)
        else:
            button_id = ctx.triggered[0]["prop_id"].split(".")[0]

        if button_id == "No clicks" or button_id == "first_date":
            subset = render_content(card_tabs, "first_date", cols, data)

        elif button_id == "second_date":
            subset = render_content(card_tabs, "second_date", cols, data)

        elif button_id == "third_date":
            subset = render_content(card_tabs, "third_date", cols, data)

        """
        button date abbreviation
        """
        first_date = str(first_date.strftime("%a"))
        second_date = str(second_date.strftime("%a"))
        third_date = str(third_date.strftime("%a"))

        """
        find the current weather icon
        """
        weather_icon = str(
            weather_icons["UrlMeteo"][
                (weather_icons["CodiceMeteo"] == subset["CodiceMeteo"].values[0])
            ].values[0]
        )

        if subset.shape[0] == 1:
            comfort = "{:.2f}".format(subset["ComfortAssoluto"].values[0])
            wind_speed = "{:.1f} km/h".format(subset["IntensitaVento"].values[0])
            wind_direction = degrees_to_cardinal(subset["DirezioneVento"].values[0])
            temperature = "{:.1f} \N{DEGREE SIGN}".format(
                subset["Temperatura"].values[0]
            )
            return (
                first_date,
                second_date,
                third_date,
                comfort,
                wind_speed,
                wind_direction,
                temperature,
                weather_icon,
            )
        else:
            print("No update: subset shape {}".format(subset.shape))
            raise PreventUpdate