###bounding-boxes (Python version)


A Python script for building bounding boxes.

A simple script for producing Gnip bounding boxes for a study area.  Gnip bounding boxes have a 
25-mile per 'side' limit.  So the script is used to produce 25-mile bounding boxes for a large area such
as Coloroado.

This script represents the prototype of what evolved into the Ruby version.

The Ruby version is available [HERE] (https://github.com/jimmoffitt/bounding-boxes/blob/master/rbBoundingBoxes/README.md) and has these additional features:

+ Supports Gnip Profile Geo profile_bounding_box Operator.
+ Enables a business rules 'element' that can be ANDed with produced geo rules.
+ ORs together bounding box up to 1024 characters.  These rules written in an atomic nature with surrounding parentheses. 
+ Enables a character buffer to be specified so space can be reserved for future rule elements.



