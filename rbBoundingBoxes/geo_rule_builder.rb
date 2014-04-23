'''
A simple class to break-up a large rectangular geographic area into smaller 25-mile square bounding boxes.
Generates both bounding_box and profile_bounding_box rules.
    * All lat/longs are in decimal degrees.
    * Code starts with the southwest corner.  Marches east, then moves up a row and repeats.
    * By default, produces a set of JSON bounding boxes: bounding_box:[west_long south_lat east_long north_lat].
    * Optionally, it can produce a simple format for direct entry into the Gnip Dashboard.

    See bounding_box.rb for a "optparse" wrapper around this class.

    Example usage:

        grb = GeoRuleBuilder.new
        grb.setStudyArea(-105,-102,41,37)
        grb.boxes = grb.build_boxes
        grb.clauses = grb.build_geo_clauses
        grb.rules = grb.build_rules
        grb.write_rules

'''

require 'json'
require 'ostruct' # Like a (Python) tuple sort of hash.  Slower performance than a plain 'o Struct, but a handy 'on the fly' data structure.

require_relative './gnip_globe'

class GeoRuleBuilder

    MAX_RULE_LENGTH = 1024
    MAX_POSITIVE_CLAUSES = 30

    attr_accessor :west, :east, :north, :south,
                  :lat_offset_default, :long_offset_default,
                  :limit_lat, :limit_long,
                  :rule_base, :tag, :buffer,
                  :profile_geo, :tweet_geo,
                  :file_path,
                  :dashboard,

                  :boxes, #Array of 25-mile boxes, with four corners.
                  :clauses, #Array of bounding box Operator clauses, one for each box.
                  :rules  #Array of rules, combinations of clauses.

    def initialize
        @boxes = Array.new
        @clauses = Array.new
        @rules = Array.new

        #Set defaults.
        @file_path = 'geo_rules.json'
        @lat_offset_default = 0.35
        @long_offset_default = 0.45
    end

    def set_study_area(west, east, north, south)
        @west = west
        @east = east
        @north = north
        @south = south
    end

    def resizeBox(long_offset, west, south)
        point1 = OpenStruct.new
        point2 = OpenStruct.new

        point1.west = west
        point1.south = south
        point2.west = west + long_offset
        point2.south = south

        distance = GnipGlobe.distance_in_mile(point1, point2)

        p "distance: #{distance}"

        if distance > 24.8 and distance <= 24.9 then
            long_offset
        else
            if distance < 24.8 then
                #These latitude driven tweaks are 100% empirical for handle boxes near the Poles.
                if south.abs < 75 then
                    long_offset = long_offset + 0.0001
                elsif south.abs < 85 then
                    long_offset = long_offset + 0.001
                else
                    long_offset = long_offset + 0.01
                end
            end
            if distance > 24.9 then
                #These latitude driven tweaks are 100% empirical for handle boxes near the Poles.
                if south.abs < 75 then
                    long_offset = long_offset - 0.0001
                elsif south.abs < 85 then
                    long_offset = long_offset - 0.001
                else
                    long_offset = long_offset - 0.01
                end
            end
            resizeBox(long_offset, point1.west, point1.south)
        end
    end

    def build_boxes(west=nil, east=nil, north=nil, south=nil)

        west = @west unless !west.nil?
        east = @east unless !east.nil?
        north = @north unless !north.nil?
        south = @south unless !south.nil?

        boxes = Array.new

        sa = OpenStruct.new
        sa.west = west.to_f
        sa.east = east.to_f
        sa.north = north.to_f
        sa.south = south.to_f

        #Make smaller near the Equator.
        if sa.north.abs < 15 or sa.south.abs < 15 then
            long_offset_default = 0.35
        end

        #Make larger near the Poles.
        if sa.north.abs > 80 or sa.south.abs > 80 then
            long_offset_default = 3 #Purely an empirical number!
        end

        offset = OpenStruct.new
        if @limit_lat.nil? then
            offset.lat = @lat_offset_default
        else
            offset.lat = @limit_lat.to_f
        end

        if @limit_long.nil? then
            offset.long = @long_offset_default
        else
            offset.long = @limit_long.to_f
        end

        #Determine the number of boxes to build.
        #How many columns needed to transverse West-East distance?
        columns = (sa.west - sa.east).abs/offset.long
        columns = columns.ceil
        #How many rows needed to transverse North-South distance?
        rows = (sa.north - sa.south)/offset.lat
        rows = rows.ceil

        p 'Expecting ' + (columns * rows).to_s + ' boxes (' + rows.to_s + ' rows X ' + columns.to_s + ' columns).'

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
            while box.west < sa.east #marching eastward, building row of boxes

                #Create bounding box. #bounding_box:[west_long south_lat east_long north_lat]

                box_temp = OpenStruct.new #Create a new object, otherwise every boxes[] element points to current object.
                box_temp.west = box.west
                box_temp.east = box.east
                box_temp.south = box.south
                box_temp.north = box.north

                #Check if northern and eastern edges extend beyond study area and snap back if necessary.
                if box_temp.north > sa.north then
                    box_temp.north = sa.north
                end
                if box_temp.east > sa.east then
                    box_temp.east = sa.east
                end

                boxes << box_temp

                #Advance eastward.
                box.west = (box.west + offset.long)
                box.east = (box.east + offset.long)
            end

            #Snap back to western edge.
            box.west = sa.west

            #Resize bounding box w.r.t. longitude offset...
            offset.long = resizeBox(offset.long, box.west, box.south)

            #Advance eastward, using new longitude offset.
            box.east = box.west + offset.long

            #Advance northward.
            box.south = (box.south + offset.lat).round(8)
            box.north = (box.north + offset.lat).round(8)

        end

        @boxes = boxes
    end

    def build_geo_clauses(boxes=nil)

        boxes = @boxes unless !boxes.nil?

        clause = ''
        clauses = Array.new

        if @tweet_geo then
            for box in boxes do
                clause = "bounding_box:[#{"%3.5f" % box.west} #{"%3.5f" % box.south} #{"%3.5f" % box.east} #{"%3.5f" % box.north}]"
                clauses.push clause
            end
        end

        if @profile_geo then
            for box in boxes do
                clause = "profile_bounding_box:[#{"%3.5f" % box.west} #{"%3.5f" % box.south} #{"%3.5f" % box.east} #{"%3.5f" % box.north}]"
                clauses.push clause
            end
        end

        @clauses = clauses

    end

    def build_rules(clauses=nil)

        clauses = @clauses unless !clauses.nil?

        rules = Array.new

        #Now assemble rule

        #At this point we should OR these rules together.
        #The limits here are:
        #    maximum length of rule, maximum PT length (set constant) minus user-specified buffer.
        #    length of 'add-on' rule clause
        #    maximum number of positive clauses #TODO

        starting_buffer = MAX_RULE_LENGTH

        if !@buffer.nil? then
            starting_buffer = MAX_RULE_LENGTH - @buffer
        end

        #Do we have have a user-specified rule element to add on?
        starting_buffer = starting_buffer - @rule_base.length

        starting_buffer = starting_buffer - 3 #the 3 is allocated for surrounding parentheses.

        empty_rule = true

        rule = ''
        current_buffer = starting_buffer

        num_of_clauses = clauses.length
        i = 0
        for clause in clauses do
            i = i + 1
            if current_buffer >= clause.length then

                if !empty_rule then
                    #add it with a preceding ' OR ' string
                    rule = "#{rule} OR #{clause}"
                else
                    #a new rule, no need for a preceding OR.
                    rule = "#{rule_base} (#{clause}"
                    empty_rule = false
                end
                current_buffer = current_buffer - clause.length

                if i == num_of_clauses then
                    rule = "#{rule}) ".strip!
                    rules << rule
                end
            else

                if i == 1 then #We have too big of a buffer, so readjust and add rule
                    rule = "#{rule_base} (#{clause}"
                    empty_rule = false
                    current_buffer = rule.length + 5
                end

                #We are done here, so add this rule to the rules array...
                rule = "#{rule}) ".strip!
                rules << rule

                #handle the clause that would have pushed us over the edge.
                rule = "#{rule_base} (#{clause}"

                if i == num_of_clauses then
                    rule = "#{rule}) ".strip!
                    rules << rule
                end

                #and initialize things.
                current_buffer = starting_buffer - clause.length
                empty_rule = false
            end
        end

        @rules = rules
    end

    def write_rules(rules = nil)

        rules = @rules unless !rules.nil?

        if not dashboard then

            rule_set = Array.new

            for rule in rules do
                #Build JSON version
                if tag == nil then
                    this_rule = {'value' => rule}
                else
                    this_rule = {'value' => rule, 'tag' => tag}
                end

                rule_set << this_rule
            end

            rule_final = Hash.new
            rule_final['rules'] = rule_set

            File.open(@file_path, 'w') do |f|
                f.write(rule_final.to_json)
            end

        else #Writing a non-JSON file for copying/pasting into Dashboard rules text box.
            contents = ""
            for rule in rules do
                contents = contents + rule + "\n"
            end

            File.open(@file_path, 'w') do |f|
                f.write(contents)
            end
        end

    end

    def do_all
        @boxes = build_boxes(@west, @east, @north, @south)
        @clauses = build_geo_clauses(@boxes)
        @rules = build_rules(@clauses)
        write_rules(@rules)
    end

end