'''
This test case checks that the divs are correctly filled by the callback.
Author: Piero Ferrarese <piero.ferrarese@nphysis.com>
'''
import sys
sys.path.append("../")
from datetime import datetime
from time import sleep 

from app import app


def test_widget001_children_filled(dash_duo):
    dash_duo.start_server(app)
    today = datetime.now()
    dash_duo.wait_for_text_to_equal("#date", "{}-{}-{}".format(today.year,
                                                              str(today.month).zfill(2),
                                                              today.day))

    dash_duo.wait_for_contains_text("#wind-speed", "km/h")

    dash_duo.percy_snapshot("widget001-layout")    

    
def test_widget002_next_update(dash_duo):
    dash_duo.start_server(app)
    sleep(2)
    dash_duo.multiple_click("#next-time", 1)

    dash_duo.wait_for_contains_text("#wind-speed", "km/h")

