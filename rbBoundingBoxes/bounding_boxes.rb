#!/usr/bin/env ruby


'''
A simple script to break-up a large rectangular geographic area into smaller 25-mile square bounding boxes.
    * All lat/longs are in decimal degrees.
    * Code starts with the southwest corner.  Marches east, then moves up a row and repeats.
    * By default, produces a set of JSON bounding boxes: bounding_box:[west_long south_lat east_long north_lat].
    * Optionally, it can produce a simple format for direct entry into the Gnip Dashboard.

    Command-line arguments:
    [] west, south, east, north, tag, filepath, limit_lat, limit_long, dashboard

'''


include Math
require 'json'
require 'optparse'
require 'ostruct' #Playing with OpenStructs, a (Python) tuple sort of hash.  Slower performance
                  #than a plain o Struct, but a handy 'on the fly' data structure.

'''
#Colorado
-w -109 -e -102 -n 41 -s 37 -t "Geo-Colorado"
#Kenya
-w 33.78 -e 42 -n 5.1 -s 4.8 -f "./kenya_geo.json"
'''

class BoundingBoxes

  PI = 3.1415926535
  EARTH_RADIUS_METERS = 5282000

  EARTH_CIRCUMFERENCE = 6378137     # earth circumference in meters
  METERS_IN_MILE = 1609.34


  def self.deg2Rad(degree)
      degree * PI / 180
  end

  def self.great_circle_distance_miles(pt1, pt2)


      dlat = deg2Rad(pt2.south - pt1.south)
      dlong = deg2Rad(pt2.west - pt1.west)

      a = sin(dlat/2) * sin(dlat/2) +
            cos(deg2Rad(pt1.south)) * cos(deg2Rad(pt2.south)) *
          sin(dlong/2) * sin(dlong/2)
      c = 2 * atan2(sqrt(a),sqrt(1-a))

      d = EARTH_CIRCUMFERENCE * c

      d / METERS_IN_MILE

  end


  def self.resizeBox(long_offset, west, south)
      point1 = OpenStruct.new
      point2 = OpenStruct.new

      point1.west =  west
      point1.south = south
      point2.west = west + long_offset
      point2.south = south

      distance = great_circle_distance_miles(point1, point2)
      #p "distance: " + distance.to_s

      if distance > 24.8 and distance <= 24.9 then
          long_offset
      else
         if distance < 24.8 then
             long_offset = long_offset + 0.001
         end
         if distance > 24.9 then
             long_offset = long_offset - 0.001
         end
         resizeBox(long_offset, point1.west, point1.south)
      end
  end

  #Set defaults.  Most appropriate for mid-latitudes.  Tested with Continental US area...
  lat_offset_default = 0.35
  long_offset_default = 0.45

  #TODO: move to OptionParser class -------------------
  #Parse command-line and set variables.
  OptionParser.new do |o|
    o.on('-w WEST') { |west| $west = west }
    o.on('-e EAST') { |east| $east = east }
    o.on('-n NORTH') { |north| $north = north }
    o.on('-s SOUTH') { |south| $south = south }
    o.on('-t TAG') { |tag| $tag = tag}
    o.on('-la LIMIT_LAT') { |limit_lat| $limit_lat = limit_lat}
    o.on('-la LIMIT_LONG') { |limit_long| $limit_long = limit_long}
    o.on('-f FILEPATH') { |filepath| $filepath = filepath}
    o.on('-d') { $dashboard = true}
    o.on('-h') {puts o; exit}
    o.parse!
  end

  sa = OpenStruct.new
  sa.west = $west.to_f
  sa.east = $east.to_f
  sa.north = $north.to_f
  sa.south = $south.to_f
  tag = $tag
  filepath = $filepath

  #dashboard provides an option to output the bounding boxes as simple text for copy/paste into Gnip dashboard.
  if $dashboard.nil? then
    dashboard = false
  else
    dashboard = true
    if filepath.nil? then
       filepath = 'geo_rules.txt'
    end
  end

  if filepath.nil? then
    filepath = 'geo_rules.json'
  end

  offset = OpenStruct.new
  if $limit_lat.nil? then
    offset.lat = lat_offset_default
  else
     offset.lat = $limit_lat.to_f
  end

  if $limit_long.nil? then
    offset.long = long_offset_default
  else
    offset.long = $limit_long.to_f
  end
  # end of appOptionParser class.



  #Determine the number of boxes to build.
  #How many columns needed to transverse West-East distance?
  columns = (sa.west - sa.east).abs/offset.long
  columns = columns.ceil
  #How many rows needed to transverse North-South distance?
  rows = (sa.north - sa.south)/offset.lat
  rows = rows.ceil

  p 'Expecting ' + (columns * rows).to_s + ' boxes (' + rows.to_s + ' rows X ' + columns.to_s + ' columns).'

  boxes = Array.new    #Create an array to hold boxes.  #Ruby lists are like a stack, with push and pop

  #Initialize Origin bounding box
  #Create a point 'origin' object.
  box = OpenStruct.new
  box.west = sa.west
  box.east = sa.west + offset.long
  box.south = sa.south
  box.north = sa.south + offset.lat

  #Walk the study area building bounding boxes.
  # Starting in SW corner, marching east, then up a row and repeat.
  while box.south < sa.north #marching northward until next row would be completely out of study area.
    while box.west < sa.east  #marching eastward, building row of boxes

      #Create bounding box. #bounding_box:[west_long south_lat east_long north_lat]

      box_temp = OpenStruct.new  #Create a new object, otherwise every boxes[] element points to current object.
      box_temp.west = box.west
      box_temp.east = box.east
      box_temp.south = box.south
      box_temp.north = box.north
      boxes << box_temp

      #Advance eastward.
      box.west = (box.west + offset.long).round(6)
      box.east = (box.east + offset.long).round(6)
    end

    #Snap back to western edge.
    box.west = sa.west

    #Resize bounding box w.r.t. longitude offset...
    offset.long = self.resizeBox(offset.long, box.west, box.south)  #TODO:
    #p offset.long

    #Advance eastward, using new longitude offset.
    box.east = box.west + offset.long

    #Advance northward.
    box.south = (box.south + offset.lat).round(6)
    box.north = (box.north + offset.lat).round(6)
  end

  p "Have " + boxes.count.to_s + " boxes."

  #Write output. Convert 'boxes' list top list of bounding_box rules

  if not dashboard then
    rules = []
    for box in boxes do
      rule_syntax = 'bounding_box:[' + box.west.to_s + ' ' + box.south.to_s + ' ' + box.east.to_s + ' ' + box.north.to_s + ']'
      #p rule_syntax
      if tag == nil then
        rule = {'value' => rule_syntax}
      else
        rule = {'value' => rule_syntax, 'tag' => tag}
      end
      rules.push rule
    end

    rule_set = Hash.new
    rule_set['rules'] = rules

    File.open(filepath,'w') do |f|
      f.write(rule_set.to_json)
    end

    #p rule_set.to_json
  else
    contents = ""
    for box in boxes do
      rule_syntax = 'bounding_box:[' + box.west.to_s + ' ' + box.south.to_s + ' ' + box.east.to_s + ' ' + box.north.to_s + ']'
      contents = contents + rule_syntax + "\n"
    end
    File.open(filepath,'w') do |f|
      f.write(contents)
    end

  end

end


