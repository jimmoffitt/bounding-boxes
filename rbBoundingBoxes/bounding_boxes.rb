#!/usr/bin/env ruby

require 'json'
require 'optparse'
require 'ostruct' #Playing with OpenStructs, a (Python) tuple sort of hash.  Much slower performance
                  #than a plain o Struct, but a handy 'on the fly' data structure.

class BoundingBoxes

  #Set defaults.
  lat_offset_default = 0.35
  long_offset_default = 0.45

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
  pt = OpenStruct.new
  pt.west = sa.west
  pt.east = sa.west + offset.long
  pt.south = sa.south
  pt.north = sa.south + offset.lat

  #Walk the study area building bounding boxes.
  # Starting in SW corner, marching east, then up a row and repeat.
  while pt.south < sa.north #marching northward until next row would be completely out of study area.
    while pt.west < sa.east  #marching eastward, building row of boxes

      #Create bounding box. #bounding_box:[west_long south_lat east_long north_lat]

      pt_temp = OpenStruct.new  #Create a new object, otherwise every boxes[] element points to current object.
      pt_temp.west = pt.west
      pt_temp.east = pt.east
      pt_temp.south = pt.south
      pt_temp.north = pt.north
      boxes << pt_temp

      #Advance eastward.
      pt.west = (pt.west + offset.long).round(6)
      pt.east = (pt.east + offset.lat).round(6)
    end

    #Snap back to western edge.
    pt.west = sa.west
    pt.east = pt.west + offset.long

    #Advance northward.
    pt.south = (pt.south + offset.lat).round(6)
    pt.north = (pt.north + offset.lat).round(6)
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


