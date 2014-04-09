bounding-boxes
==============
Simple scripts to break-up a large rectangular geographic area into smaller 25-mile square bounding boxes.
   * All lat/longs are in decimal degrees.
   * Code starts with the southwest corner.  Marches east, then moves up a row and repeats.
   * By default, produces a set of JSON bounding boxes: bounding_box:[west_long south_lat east_long north_lat]. 
   * Optionally, it can produce a simple format for direct entry into the Gnip Dashboard.   

Currently this script is available in Ruby and Python. The Python code represents an early design, while the Ruby code is more up to date.

* Recent updates
     * command-line details for over-riding default decimal degrees 25-mile boxes.
     * default longitude distance is a function of latitude. 


Command-line options:

  * -w  (--west)   West longitude in decimal degrees. 
  * -e  (--east)   East longitude in decimal degrees. 
  * -n  (--north)  North latitude in decimal degrees. 
  * -s' (--south)  South latitude in decimal degrees. 
  
Optional:

  * -a (--limit_lat) Maximum bounding box decimal degree latitude size, must be <= 25 miles.  Defaults to 0.35 decimal degrees.
  * -o (--limit_long) Maximum bounding box decimal degree longitude size, must be <= 25 miles. Defaults to 0.45 decimal degrees.

  * -t (--tag) The rule tag to apply to the generated bounding box rules. 
  * -f (--filepath) File name (and its path) for the JSON rules to get written to. If not provided a file named geo_rules.json is written to local directory.
    
  * -d (--dashboard) Instead of the Gnip JSON rules format, it produces a simple format for direct system entry using the Gnip Dashboard. Default filename is 				geo_rules.txt.  NOTE: Tags are not supported when using Dashboard.  
   

These example command-line arguments:

	-w -103.987 -e -102.734 -n 40.417 -s 39.900 -t "geo-rules" -f "./bounding-boxes.json"

will produce this output:
```
{"rules":[
	{"value":"bounding_box:[-103.98700 39.90000 -103.55705 40.24000]","tag":"geo-rules"},
	{"value":"bounding_box:[-103.55705 39.90000 -103.12710 40.24000]","tag":"geo-rules"},
	{"value":"bounding_box:[-103.12710 39.90000 -102.73400 40.24000]","tag":"geo-rules"},
	{"value":"bounding_box:[-103.98700 40.24000 -103.51965 40.41700]","tag":"geo-rules"},
	{"value":"bounding_box:[-103.51965 40.24000 -103.05230 40.41700]","tag":"geo-rules"},
	{"value":"bounding_box:[-103.05230 40.24000 -102.73400 40.41700]","tag":"geo-rules"}
]}
```
