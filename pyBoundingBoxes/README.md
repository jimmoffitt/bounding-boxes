### bounding-boxes (Python version)


#### Background

A Python script for building bounding boxes.

A simple script for producing Tweet geotagged bounding boxes for large study areas.  Bounding boxes have a 
25-mile per 'side' limit.  So the script is designed to produce matrices of 25-mile bounding boxes for large areas such
as Coloroado.

This script represents the prototype of what evolved into the Ruby version. 

Note that this Python version does not support [Profile Geo](https://developer.twitter.com/en/docs/tweets/enrichments/overview/profile-geo) bounding boxes, while the Ruby version does.

The Ruby version is available [HERE](https://github.com/jimmoffitt/bounding-boxes/blob/master/rbBoundingBoxes/README.md) and has these additional features:

+ Supports Twitter [Profile Geo](https://developer.twitter.com/en/docs/tweets/enrichments/overview/profile-geo) profile_bounding_box Operator.
+ Enables a business rules 'element' that can be ANDed with produced geo rules.
+ ORs together bounding box up to 1024 characters.  These rules written in an atomic nature with surrounding parentheses. 
+ Enables a character buffer to be specified so space can be reserved for future rule elements.

#### Usage

Command-line options:

  * -w  (--west)   West longitude in decimal degrees. 
  * -e  (--east)   East longitude in decimal degrees. 
  * -n  (--north)  North latitude in decimal degrees. 
  * -s' (--south)  South latitude in decimal degrees. 
  
Optional:

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



