"""
This module contains utility functions. 
Author: Piero Ferrarese <piero.ferrarese@nphysis.com>
"""


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
