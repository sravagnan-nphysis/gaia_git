# DAYTIMES = [("Mattina", 6, 12),
# 	    ("Pomeriggio", 12, 18),
# 	    ("Sera", 18, 24),
#             ("Notte", 0, 6)]
DAYTIMES = [("Mattina", 0, 12),
            ("Pomeriggio", 12, 24)]

def degrees_to_cardinal(d):
    '''
    '''
    dirs = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
            "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    ix = int((d + 11.25)/22.5)
    return dirs[ix % 16]
