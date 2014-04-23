#!/usr/bin/env ruby

'''
A simple class to break-up a large rectangular geographic area into smaller 25-mile square bounding boxes.
Generates both bounding_box and profile_bounding_box rules.
    * All lat/longs are in decimal degrees.
    * Code starts with the southwest corner.  Marches east, then moves up a row and repeats.
    * By default, produces a set of JSON bounding boxes: bounding_box:[west_long south_lat east_long north_lat].
    * Optionally, it can produce a simple format for direct entry into the Gnip Dashboard.
'''


require 'optparse'
require_relative './geo_rule_builder'


'' '
#Colorado
-w -109 -e -102 -n 41 -s 37 -t "Geo-Colorado" -f "./colorado-boxes.json"
#NW Colorado
-w -106 -e -102 -n 41 -s 39 -t "geo-colorado-nw" -f "./colorado-nw-boxes.json"
#Kenya
-w 33.78 -e 42 -n 5.1 -s 4.8 -f "./kenya_geo.json"
' ''

class BoundingBoxes

    grb = GeoRuleBuilder.new

    #TODO: move to OptionParser class -------------------
    #Parse command-line and set variables.
    OptionParser.new do |o|
        o.on('-w WEST') { |west| grb.west = west }
        o.on('-e EAST') { |east| grb.east = east }
        o.on('-n NORTH') { |north| grb.north = north }
        o.on('-s SOUTH') { |south| grb.south = south }
        o.on('-r RULE') { |rule| grb.rule_base = rule }
        o.on('-t TAG') { |tag| grb.tag = tag }
        o.on('-b BUFFER') { |buffer| grb.buffer = buffer }
        o.on('-p') { grb.profile_geo = true }
        o.on('-g') { grb.tweet_geo = true }
        o.on('-a LIMIT_LAT') { |limit_lat| grb.imit_lat = limit_lat }
        o.on('-o LIMIT_LONG') { |limit_long| grb.limit_long = limit_long }
        o.on('-f FILEPATH') { |filepath| grb.filepath = filepath }
        o.on('-d') { grb.dashboard = true }
        o.on('-h') { puts o; exit }
        o.parse!
    end

    #Input validation ----------------------------

    if grb.rule_base.nil? then
        grb.rule_base = ''
    else #Always group rule base with parentheses, unless there are just 2 parentheses...
        if (grb.rule_base.count("(-)") != 2) or (grb.rule_base.count("(-)") == 2 and (grb.rule_base[0] != "(" or grb.rule_base[-1] != ")")) then
            grb.rule_base = "(#{grb.rule_base})"
        end
    end

    if grb.buffer.nil? then
        grb.buffer = 0
    else
        grb.buffer = grb.buffer.to_i
    end

    if grb.profile_geo.nil? and grb.tweet_geo.nil? then
        tweet_geo = true #Default
    end

    if grb.profile_geo.nil? then
        grb.profile_geo = false
    else
        grb.profile_geo = true
    end

    if grb.tweet_geo.nil? then
        grb.tweet_geo = false
    else
        grb.tweet_geo = true
    end

    if grb.file_path.nil? then
        grb.file_path = 'geo_rules.json'
    end

    #dashboard provides an option to output the bounding boxes as simple text for copy/paste into Gnip dashboard.
    if grb.dashboard.nil? then
        grb.dashboard = false
    else
        grb.dashboard = true
        if grb.file_path.nil? then
            grb.file_path = 'geo_rules.txt'
        else #just make sure it is a txt extension.
            if grb.file_path.include?(".json") then
                grb.file_path["json"] = "txt"
            end
        end
    end

    #OK, go generate the rules.
    grb.do_all

end


