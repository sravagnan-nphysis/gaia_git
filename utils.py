"""
This module contains utility functions. 
Author: Piero Ferrarese <piero.ferrarese@nphysis.com>
"""
import pandas as pd


def degrees_to_cardinal(degree: float) -> str:
    """
    This function converts the wind direction from degrees to cardinal.

    Parameters
    ----------
    degree: float
            The value of the degree to convert

    Returns
    -------
    dir_label : str
                The label of the direction

    """
    dirs = [
        "N",
        "NNE",
        "NE",
        "ENE",
        "E",
        "ESE",
        "SE",
        "SSE",
        "S",
        "SSW",
        "SW",
        "WSW",
        "W",
        "WNW",
        "NW",
        "NNW",
    ]
    ix = int((degree + 11.25) / 22.5)
    dir_label = dirs[ix % len(dirs)]
    return dir_label


def render_content(tab, date, cols, data) -> pd.DataFrame:
    """
    This function updates the data in the widget, depending on user inputs,
    which are either browsing to date buttons and tabs.
    The function filters the weather data based on the selected input by user.

    Parameters:
    -----------
    tab : str
                Info reguards which tab has been selected by user
    date : str
                Info reguards which date has been selected by user
    cols : list
                Variable list of interest
    data : dataframe
                The dataframe that contains all the data requested from api


    Returns:
    --------
    subset : str
           The dataframe filtered by user inputs
    """

    if date == "first_date":
        date = pd.Timestamp.today()
    elif date == "second_date":
        date = pd.Timestamp.today() + pd.Timedelta("1 days")
    elif date == "third_date":
        date = pd.Timestamp.today() + pd.Timedelta("2 days")

    if tab == "morning_tab":
        subset = data.loc[
            (data["Idloc"] == data["Idloc"].unique()[0])
            & (data["Data"] == str(date)[:10])
            & (data["EtichettaGiorno"] == "Mattina"),
            cols,
        ]
        return subset
    elif tab == "afternoon_tab":
        subset = data.loc[
            (data["Idloc"] == data["Idloc"].unique()[0])
            & (data["Data"] == str(date)[:10])
            & (data["EtichettaGiorno"] == "Pomeriggio"),
            cols,
        ]
        return subset
