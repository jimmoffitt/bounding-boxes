import math

'''
    So far, a random collection of geographic routines.

    Decimal Degrees only
    GCS NAD83
'''
    #TODO: Datum details.
    #TODO: Projection details.
'''
    Started with sphere-surface calculations such as:
        * distance between two points.
        * the decimal degree offset from a single point:
            Example:  the DD location 25 miles

    Need to be able to inspect a shapefile and build the appropriate bounding boxes.

    Supported units:
        math: meters
        distance: miles, kilometers, meters.

    Fundamental test locations: four hemispheres, two intersections and two poles.

    Some References:
            http://en.wikipedia.org/wiki/Great_circle  <-- start here.
            http://mathworld.wolfram.com/GreatCircle.html  <-- background math.
            https://gist.github.com/1826175  <-- Python code for sphere distance.

'''

class GnipGlobe():

    def __init__(self):
        pass

    def getDistance2Points(self,latlong_a, latlong, unit="miles"):
        pass


    def getDistanceBox(self,latlong,distance,unit="miles"):
        pass

def great_circle_distance(latlong_a, latlong_b):

    EARTH_CIRCUMFERENCE = 6378137     # earth circumference in meters

    """
    >>> coord_pairs = [
    ...     # between eighth and 31st and eighth and 30th
    ...     [(40.750307,-73.994819), (40.749641,-73.99527)],
    ...     # sanfran to NYC ~2568 miles
    ...     [(37.784750,-122.421180), (40.714585,-74.007202)],
    ...     # about 10 feet apart
    ...     [(40.714732,-74.008091), (40.714753,-74.008074)],
    ...     # inches apart
    ...     [(40.754850,-73.975560), (40.754851,-73.975561)],
    ... ]

    >>> for pair in coord_pairs:
    ...     great_circle_distance(pair[0], pair[1]) # doctest: +ELLIPSIS
    83.325362855055...
    4133342.6554530...
    2.7426970360283...
    0.1396525521278...
    """
    lat1, lon1 = latlong_a
    lat2, lon2 = latlong_b

    dLat = math.radians(lat2 - lat1)
    dLon = math.radians(lon2 - lon1)
    a = (math.sin(dLat / 2) * math.sin(dLat / 2) +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dLon / 2) * math.sin(dLon / 2))
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    d = EARTH_CIRCUMFERENCE * c

    return d


def getBoundingBoxSize():
    pass

'''
F(P1, P2) ==> D       --->                F(P1, D) = P2


	lat1, lon1 = latlong_a
	lat2, lon2 = latlong_b

    dLat = radians(lat2 - lat1)
    dLon = radians(lon2 - lon1)
    a = (sin(dLat / 2) * sin(dLat / 2) +
         cos(radians(lat1)) * cos(radians(lat2)) *
         sin(dLon / 2) * sin(dLon / 2))
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    d = EC * c

 return d


Given lat1, lon1, D --> solve for lat2, lon2

c  = d/ED

d/EC = 2 *atan2(sqrt(a), sqrt(1 - a))  <-- solve for a

'''