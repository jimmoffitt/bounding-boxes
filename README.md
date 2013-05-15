bounding-boxes
==============
Simple scripts to break-up a large rectangular geographic area into smaller 25-mile square bounding boxes.
   * All lat/longs are in decimal degrees.
   * Code starts with the southwest corner.  Marches east, then moves up a row and repeats.
   * By default, produces a set of JSON bounding boxes: bounding_box:[west_long south_lat east_long north_lat]. 
   * There is an option (-t) to specify a rule tag for the bounding boxes produced.
   * There is an option (-f) to specify a filename and path for writing the file.  If no filename is specified,
     it defaults to geo-rules.json.  	
   * Optionally, it can produce a simple format for direct entry into the Gnip Dashboard.

Currently there are scripts written in Ruby and Python.  

These example command-line arguments:

	-w -103.987 -e -102.734 -n 40.417 -s 39.900 -t "geo-rules" -f "./bounding-boxes.json"

will produce this output:

{"rules":[
	{"value":"bounding_box:[-103.98700 39.90000 -103.55705 40.24000]","tag":"geo-rules"},
	{"value":"bounding_box:[-103.55705 39.90000 -103.12710 40.24000]","tag":"geo-rules"},
	{"value":"bounding_box:[-103.12710 39.90000 -102.73400 40.24000]","tag":"geo-rules"},
	{"value":"bounding_box:[-103.98700 40.24000 -103.51965 40.41700]","tag":"geo-rules"},
	{"value":"bounding_box:[-103.51965 40.24000 -103.05230 40.41700]","tag":"geo-rules"},
	{"value":"bounding_box:[-103.05230 40.24000 -102.73400 40.41700]","tag":"geo-rules"}
]}