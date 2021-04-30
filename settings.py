""" 
This module contains global variables and configurations
Author: Stefano Ravagnan <stefano.ravagnan@nphysis.com>
"""
DAYTIMES = [("Mattina", 0, 12), ("Pomeriggio", 12, 24)]

API_COMPRENSORI_URL = "http://52.178.32.64:2501/meteoski/comprensori/"

PostgreSQL = {
    "user": "meteoski",
    "password": "met3osk1",
    "host": "52.178.32.64",
    "port": "5432",
    "database": "meteoski",
}