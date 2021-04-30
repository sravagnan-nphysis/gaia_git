"""
This module contains all the functions employed to query the Meteoski API.

TODO password is in plain text. Obscure it and gets the module secure.

TODO raise proper exceptions for status_code other than 200.

Author: Stefano Ravagnan <stefano.ravagnan@nphysis.com>
"""
from typing import Dict

import requests
import settings
import pandas as pd
import pandas.io.sql as psql
import psycopg2
import sqlalchemy


def get_token(
    credentials: Dict[str, str] = {"username": "meteoski", "password": "idlocs65kHGXb"}
) -> str:
    """
    This function requests the JWT token for authorizing the Meteoski API.
    Parameters
    ----------
    credentials : dict
                  The dict containing the username and password
                  to identify the users.
    Returns
    -------
    access_token : str
                   The JWT access token valid for 30 minutes.
    """
    url = "http://52.178.32.64:2501/token"
    payload = credentials
    r = requests.post(url, data=payload)
    if r.status_code == 200:
        return eval(r.text)["access_token"]
    else:
        return ""


def get_data(token: str) -> str:
    """
    This function gets the token and requests the /meteoski/comprensori
    """
    headers = {"Accept": "application/json", "Authorization": "Bearer {}".format(token)}
    r = requests.get(settings.API_COMPRENSORI_URL, headers=headers)
    if r.status_code == 200:
        return eval(r.text)
    else:
        return ""


def get_weather_icons() -> pd.DataFrame:
    """
    This function gets the weather icons from postgres

    Returns
    -------
    df : pd.DataFrame
         A table that contains the map for associating "CodiceMeteo" to its url link
         in order to get the proper weather icon
    """
    postgres_engine = sqlalchemy.create_engine(
        "postgresql://{}:{}@{}:{}/{}".format(
            settings.PostgreSQL["user"],
            settings.PostgreSQL["password"],
            settings.PostgreSQL["host"],
            settings.PostgreSQL["port"],
            settings.PostgreSQL["database"],
        )
    )
    with postgres_engine.connect() as connection:
        PostgreSQL_data_frame = psql.read_sql(
            'SELECT * FROM api."Url_Meteoski"', connection
        )
    return PostgreSQL_data_frame


if __name__ == "__main__":
    token = get_token()
