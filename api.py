import requests


def get_token(credentials={"username": "meteoski",
                           "password": "idlocs65kHGXb"}):
    url = "http://52.178.32.64:2501/token"
    payload = credentials
    r = requests.post(url, data=payload)
    if r.status_code==200:
        return eval(r.text)['access_token']
    else:
        return None


def get_data(token):
    url = "http://52.178.32.64:2501/meteoski/comprensori/"
    headers = {"Accept": "application/json",
               "Authorization": "Bearer {}".format(token)}
    r = requests.get(url, headers=headers)
    if r.status_code==200:
        return eval(r.text)
    else:
        return None

if __name__=='__main__':
    token = get_token()
    print(get_data(token))
