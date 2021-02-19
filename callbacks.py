"""
This module contains the callbacks implementing the dynamical logic 
of the webapp.
Author: Piero Ferrarese <piero.ferrarese@nphysis.com>
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
from utils import degrees_to_cardinal


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
            Output("date", "children"),
            Output("daytime", "children"),
            Output("weather-summary", "src"),
            Output("wind-speed", "children"),
            Output("wind-direction", "children"),
            Output("temperature", "children"),
        ],
        [
            Input("update", "n_intervals"),
            Input("previous-time", "n_clicks"),
            Input("next-time", "n_clicks"),
        ],
        [State("date", "children"), State("daytime", "children")],
    )
    def update_widget(
        interval: int, previous: int, after: int, current_date: str, current_time: str
    ) -> Tuple[str, str, str, float, str, float]:
        """
        This function updates the widget every interval time set, depending on user inputs,
        which are either browsing to previous or next time instant.
        The function updates the weather summary icon according to the Meteoski
        comfort index color.
        The function first gets the token, then query the data and filter them according
        the requested input.
        Depending on what triggered the callback, the current date/daytime is changed, depending
        on what was last exposed.
        When it is called at page loading, it displays current date/time.

        Parameters:
        -----------
        interval : int
                   A counter of the number of intervals passed from the startup of the app
        previous : int
                   A counter of the number of n_clicks the previous-time button has been clicked
        next : int
                   A counter of the number of n_clicks the next-time button has been clicked
        current_date : str
                       The content of the date div - a string with the date displayed
        current_time : str
                       The content of the daytime div - a string with time of the day

        Returns:
        --------
        date : str
               The date displayed
        day_label : str
                    The label of the datetime displayed
        img_url : str
                  The url of the meteoski widget - green/yellow/red

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
        data = pd.DataFrame(api.get_data(token))
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
        ]
        data[all_keys] = data["Overviews"].apply(lambda x: pd.Series(x))
        ctx = dash.callback_context
        if not ctx.triggered:
            button_id = "No clicks"
        else:
            button_id = ctx.triggered[0]["prop_id"].split(".")[0]
        if button_id == "No clicks":
            daytimes = pd.DataFrame(
                settings.DAYTIMES, columns=["label", "beginning", "end"]
            )
            hour = pd.Timestamp.today().hour

            day_label = daytimes.loc[
                (daytimes["beginning"] <= hour) & (daytimes["end"] > hour), "label"
            ].values[0]
            date = str(pd.Timestamp.today())[:10]

            subset = data.loc[
                (data["Idloc"] == data["Idloc"].unique()[0])
                & (data["Data"] == date)
                & (data["EtichettaGiorno"] == day_label),
                cols,
            ]
        elif button_id == "previous-time" or button_id == "next-time":
            date = pd.to_datetime(current_date)
            if current_time == "Mattina":
                day_label = "Pomeriggio"
                if button_id == "previous-time":
                    date -= pd.DateOffset(1)
            elif current_time == "Pomeriggio":
                day_label = "Mattina"
                if button_id == "next-time":
                    date += pd.DateOffset(1)
            date = str(date)[:10]
            subset = data.loc[
                (data["Idloc"] == data["Idloc"].unique()[0])
                & (data["Data"] == date)
                & (data["EtichettaGiorno"] == day_label),
                cols,
            ]

        if subset.shape[0] == 1:
            img_url = "https://www.meteoski.it/assets/site/img/tag_{}.png".format(
                subset["Colore"].values[0].lower()
            )
            wind_speed = "{:.1f} km/h".format(subset["IntensitaVento"].values[0])
            wind_direction = degrees_to_cardinal(subset["DirezioneVento"].values[0])
            temperature = "{:.1f} \N{DEGREE SIGN}".format(
                subset["Temperatura"].values[0]
            )

            return (date, day_label, img_url, wind_speed, wind_direction, temperature)
        else:
            print("No update: subset shape {}".format(subset.shape))
            raise PreventUpdate
