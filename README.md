### bounding-boxes

Simple scripts to break-up a large rectangular geographic area into smaller 25-mile square bounding boxes.
   * All lat/longs are in decimal degrees.
   * Code starts with the southwest corner.  Marches east, then moves up a row and repeats.
   * By default, produces a set of JSON bounding boxes: bounding_box:[west_long south_lat east_long north_lat]. 
   * Optionally, it can produce a simple format for direct entry into the Gnip Dashboard.   

This script is available in Ruby and Python. 

The [Python code](https://github.com/jimmoffitt/bounding-boxes/tree/master/pyBoundingBoxes) represents an early prototype design.

The [Ruby code](https://github.com/jimmoffitt/bounding-boxes/tree/master/rbBoundingBoxes) has been extended with additional features:

+ Supports Profile Geo profile_bounding_box Operator.
+ Enables a business rules 'element' that can be ANDed with generated geo rules.
+ ORs together bounding box up to 1024 characters. These rules written in an atomic nature with surrounding parentheses.
+ Enables a character buffer to be specified so space can be reserved for future rule elements.




