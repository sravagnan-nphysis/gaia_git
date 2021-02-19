"""
This module contains all the functions employed to query the Meteoski API.

TODO password is in plain text. Obscure it and gets the module secure.

TODO raise proper exceptions for status_code other than 200.

Author: Piero Ferrarese <piero.ferrarese@nphysis.com>
"""
from typing import Dict

import requests

import settings


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


if __name__ == "__main__":
    token = get_token()
    print(get_data(token))
