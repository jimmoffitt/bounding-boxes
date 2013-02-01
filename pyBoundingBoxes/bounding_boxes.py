#!/usr/bin/env python

'''
    A simple script to break-up a large rectangular geographic area into smaller 25-mile square bounding boxes.

    * All lat/longs are in decimal degrees.
    * Code starts with the southwest corner. 'Marches' east, then moves up a 'row' and repeats.
    * By default, produces a set of JSON bounding boxes: bounding_box:[west_long south_lat east_long north_lat].
    * Optionally, it can produce a simple format for direct entry into the Gnip Dashboard.

    Command-line arguments:
        [] west, south, east, north, tag, filepath, limit_lat, limit_long, dashboard

'''

'''
usage: bounding_boxes.py [-h] [-w WEST] [-e EAST] [-n NORTH] [-s SOUTH]
                         [-la LIMIT_LAT] [-lo LIMIT_LONG] [-t TAG]
                         [-f FILEPATH] [-d]

A script for breaking a large rectangular geographic area into ~25-mile
bounding boxes.

optional arguments:
  -h, --help            show this help message and exit
  -w WEST, --west WEST  West longitude in decimal degrees.
  -e EAST, --east EAST  East longitude in decimal degrees.
  -n NORTH, --north NORTH
                        North latitude in decimal degrees.
  -s SOUTH, --south SOUTH
                        South latitude in decimal degrees.
  -la LIMIT_LAT, --limit_lat LIMIT_LAT
                        Maximum bounding box decimal degree latitude size,
                        must be <= 25 miles. Defaults to 0.35 degrees
                        latitude.
  -lo LIMIT_LONG, --limit_long LIMIT_LONG
                        Maximum bounding box decimal degree longitude size,
                        must be <= 25 miles. Defaults to 0.45 degrees
                        longitude.
  -t TAG, --tag TAG     The rule tag to apply to the generated bounding box
                        rules.
  -f FILEPATH, --filepath FILEPATH
                        File name (and its path) for the JSON rules to get
                        written to. If not provided a file named
                        geo_rules.json is written to local directory.
  -d, --dashboard       Instead of the Gnip JSON rules format, it produces a
                        simple format for direct system entry using the Gnip
                        Dashboard. Default file name is geo_rules.txt NOTE:
                        Tags are not supported when using Dashboard.

Note: this script currently does not work for bounding boxes crossing the
Antimeridian (where E180 becomes W180). Another note: script now has logic to
dynamically size the bounding box longitude offset (width) and resize as it
creates new rows.
'''

#TODO: Add error handling.  Particularly around file IO.
#TODO: Could add input validation for latitudes (N > S), not so much for longitude.
#TODO: Add new logic to handle bounding boxes straddle the Antimeridian (where E180 becomes W180).
#TODO: Adding more functionality?  Push that code out to external classes...
#      Option to OR a specified number of bounding boxes into single rules
#      Option to AND a specified rule group to each bounding box rule.
#DONE:
#Refactor the Great Circle function to use as a 'auto-tune' box sizer...
#       Probably only relevant for very large study areas, like continental scales.
#need to address the 'decimal precision' issue.
#need to test in all hemispheres... Does this work in South America, Equator, Japan, and New Zealand?
#Add real math to come up with better defaults for lat/long limits for bounding box size.
#   The current defaults should work for the Continental USA, but perhaps not for regions with
#   latitudes between -26 and 26.
#   For these reasons script supports passing in custom limits.
#   "Great Circle" math could be implemented for a more general solution.  Copied in a sample
#   Python "Great Circle" function at the end of this...
#       Some References:
#           http://en.wikipedia.org/wiki/Great_circle  <-- start here.
#           http://mathworld.wolfram.com/GreatCircle.html  <-- background math.
#           https://gist.github.com/1826175  <-- Python code for sphere distance.


'''
   Saved command lines:

   --west --east --north --south --tag --filepath

   #USA
   -w -125 -e -67.5 -n 49 -s 26 -f "../output/geo_usa_cont.json"
   #Colorado
   -w -109 -e -102 -n 41 -s 37 -t "Geo-Colorado"
   #Continental USA extents with random digits for testing, no ruleset tag, default file location and name
   -w -125.75 -e -67.53 -n 49.35 -s 28.95
   #Equator, roughly.
   -w -81.45 -e -75.2 -n 1.45 -s -5.1 -la 0.5 -lo 0.4 -t "geo-equator" -f "../output/geo_equator.json"
   #New Zealand
   -w 165.634 -e 172.956 -n -34.124 -s -47.698
   #Japan
   -w 127.686 -e 148.364 -n 46.232 -s 29.544 -f "../output/geo_japan.json"
   #Australia
   -w 112.5 -e 155.5 -n -10 -s -44.4 -f "../output/geo_australia.json"
   #Kenya
   -w 33.78 -e 42 -n 5.1 -s 4.8 -f "./kenya_geo.json"

'''

import argparse
import math
import json


'''
   longlat parameters are long/lat tuples, such as (-73.99527,40.749641).
'''


def great_circle_distance_miles(longlat_a, longlat_b):

    EARTH_CIRCUMFERENCE = 6378137     # earth circumference in meters
    METERS_IN_MILE = 1609.34

    lon1, lat1 = longlat_a
    lon2, lat2 = longlat_b

    dLat = math.radians(lat2 - lat1)
    dLon = math.radians(lon2 - lon1)
    a = (math.sin(dLat / 2) * math.sin(dLat / 2) +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dLon / 2) * math.sin(dLon / 2))
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    d = EARTH_CIRCUMFERENCE * c

    return d / METERS_IN_MILE


'''
    Recursisvely call great_circle_distance_miles(latlong_a, latlong_b) with current 2 points and
    adjust until 24.9 < X <= 25.00 miles.
'''
def resizeBox(long_offset, long, lat):

    point1 = (long, lat)
    point2 = (long + long_offset, lat)

    distance = great_circle_distance_miles(point1, point2)
    #print 'distance = ' + str(distance)

    if distance > 24.8 and distance <=24.9:
        #print 'Bingo with long_offset=' + str(long_offset)
        return long_offset
    else:
        if distance < 24.8:
            long_offset = long_offset + 0.001
        if distance > 24.9:
            long_offset = long_offset - 0.001
        #print 'Resizing again...'
        return resizeBox(long_offset,long, lat)


if __name__ == "__main__":

    '''
        Determining the default decimal lat/long number that represents 25 miles...
        Initial (simple) calculations were based on http://www.nhc.noaa.gov/gccalc.shtml
        Tested with Continental USA bounding box with these extents:
            West: -125  East: -67.5     North: 49   South: 26

    '''
    #These default offsets are based on ~25 miles...   Well, in Continental USA.
    lat_offset_default = 0.35
    long_offset_default = 0.45

    parser = argparse.ArgumentParser(description='A script for breaking a large rectangular geographic area into '
                                                 '~25-mile bounding boxes.  ', epilog='Note: this script currently does '
                                                 'not work for bounding boxes crossing the Antimeridian (where E180 '
                                                 'becomes W180).      ' + '\n'  + 'Another note: script now has logic to '
                                                 'dynamically size the bounding box longitude offset (width) and '
                                                 'resize as it creates new rows.' )
    #The box extents are required.
    parser.add_argument('-w', '--west', type=float, help='West longitude in decimal degrees. ')
    parser.add_argument('-e', '--east', type=float, help='East longitude in decimal degrees. ')
    parser.add_argument('-n', '--north', type=float, help='North latitude in decimal degrees. ')
    parser.add_argument('-s', '--south', type=float, help='South latitude in decimal degrees. ')
    #These are optional.
    parser.add_argument('-la', '--limit_lat', help='Maximum bounding box decimal degree latitude size, must be <= 25 miles.  '
                                                   'Defaults to ' + str(lat_offset_default) + ' degrees latitude.')
    parser.add_argument('-lo', '--limit_long', help='Maximum bounding box decimal degree longitude size, must be <= 25 miles. '
                                                    'Defaults to ' + str(long_offset_default) + ' degrees longitude.')

    parser.add_argument('-t', '--tag', help='The rule tag to apply to the generated bounding box rules. ')
    parser.add_argument('-f', '--filepath', help='File name (and its path) for the JSON rules to get written to. If not '
                                                 'provided a file named geo_rules.json is written to local directory.')
    parser.add_argument('-d', '--dashboard', action="store_true", default = False, help='Instead of the Gnip JSON rules format, '
                                                'it produces a simple format for direct system entry using the Gnip Dashboard. '
                                                'Default file name is geo_rules.txt  '
                                                'NOTE: Tags are not supported when using Dashboard.  ')

    #Load command-line arguments.
    args = parser.parse_args()

    #lat, longs are mandatory.
    if args.west == None:
        parser.error("West -w must be passed in...")
    if args.east == None:
        parser.error("East -e must be passed in...")
    if args.north == None:
        parser.error("North -n must be passed in...")
    if args.south == None:
        parser.error("South -s must be passed in...")

    #Load big box extents.
    long_west = args.west
    long_east = args.east
    lat_north = args.north
    lat_south = args.south

    #Load latitude bounding box limit.
    if args.limit_lat == None:
        lat_offset = lat_offset_default
    else:
        lat_offset = args.limit_lat

    #Load longitude bounding box limit.
    if args.limit_long == None:
        long_offset = long_offset_default
    else:
        long_offset = args.limit_long

    #Load tag, if provided.
    if args.tag == None:
        tag = None
    else:
        tag = args.tag

    #Load the option for the Dashboard format (one bounding box per line)
    dashboard = args.dashboard

    #Load file & path, if provided.
    if args.filepath == None:
        if dashboard == False:
            filepath = './geo_rules.json'
        else:
            filepath = './geo_rules.txt'
    else:
        filepath = args.filepath

    #How many columns needed to transverse West-East distance?
    columns = math.fabs(long_west - long_east)/long_offset
    #print 'Fractional columns: ' + str(columns)
    columns = math.ceil(columns)

    #How many rows needed to transverse North-South distance?
    rows = math.fabs(lat_north - lat_south)/lat_offset
    #print 'Fractional rows: ' + str(rows)
    rows = math.ceil(rows)

    print 'Expecting ' + str(rows*columns) + ' boxes (' + str(rows) + ' rows X ' + str(columns) + ' columns)'

    boxes = [] #Create list to hold

    #Confirm default longitude offset
    long_offset = resizeBox(long_offset, long_west, lat_south)

    #Initialize Origin bounding box
    cur_west = long_west
    cur_east = cur_west + long_offset
    cur_south = lat_south
    cur_north = lat_south + lat_offset

    #Walk the study area building bounding boxes.
    # Starting in SW corner, marching east, then up a row and repeat.
    #while round(cur_south,6)  < round(lat_north,6):
    #    while round(cur_west,6) < round(long_east,6):
    while cur_south  < lat_north:  #marching northward until next row would be completely out of study area.
        while cur_west < long_east:  #marching eastward, building row of boxes

            #Doing some rounding to create 'clean' numbers.
            bounding_box = (round(cur_west,6), round(cur_south,6), round(cur_east,6), round(cur_north,6))
            #print bounding_box
            boxes.append(bounding_box)

            #Advance eastward.
            cur_west = cur_west + long_offset
            cur_east = cur_east + long_offset

        #Snap back to western edge.
        cur_west = long_west

        #Resize bounding box w.r.t. longitude offset...
        long_offset = resizeBox(long_offset,cur_west, cur_south)

        #Advance eastward, using new longitude offset.
        cur_east = cur_west + long_offset

        #Advance northward.
        cur_south = cur_south + lat_offset
        cur_north = cur_north + lat_offset

    print "Have " + str(len(boxes)) + " boxes."

    #Write output.
    if dashboard == True: #Writing a simple format for entry using Dashboard
        outfile = open(filepath, 'w')
        for box in boxes:
             rule_syntax = 'bounding_box:[' + str(box[0]) + ' ' + str(box[1]) + ' ' + str(box[2]) + ' ' + str(box[3]) + ']'
             outfile.write(rule_syntax + '\n')
        outfile.close()
    else: #Produce JSON formatted rule set.
        rules = []
        for box in boxes:
            #Build actual Gnip bounding box format
            rule_syntax = 'bounding_box:[' + str(box[0]) + ' ' + str(box[1]) + ' ' + str(box[2]) + ' ' + str(box[3]) + ']'
            if tag == None:
                rule = {"value":rule_syntax}
            else: rule = {"value":rule_syntax, "tag":tag}
            rules.append(rule)

        boxesDict = {}
        boxesDict['rules'] = rules

        #Write rules to file.
        with open(filepath,'w+') as outfile:
            json.dump(boxesDict, outfile)


































