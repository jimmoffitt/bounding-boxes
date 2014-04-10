##bounding-boxes (Ruby version)

A Ruby script for building bounding boxes.

###Introduction

A simple script for producing Gnip bounding boxes for a study area.  Gnip bounding boxes have a 
25-mile per 'side' limit.  So the script is used to produce 25-mile bounding boxes for a large area such
as Coloroado.


+ Supports Gnip Profile Geo profile_bounding_box Operator.
+ Enables a business rules 'element' that can be ANDed with produced geo rules.
+ ORs together bounding box up to 1024 characters. These rules written in an atomic nature with surrounding parentheses.
+ Enables a character buffer to be specified so space can be reserved for future rule elements.



+ All lat/long coordinates are in decimal degrees.
+ 'Study area' refers to the area you want to generate (25-mile) bounding boxes for.

###Usage

The following parameters are used to specify the rule you are after:

    Study area coordinates in decimal degrees (required):
    -w  => Western longitude.
    -e  => Eastern longitude. 
    -n  => North latitude.
    -s  => South latitude.
    
    
    Rule construction details:
    -r  => Rule value element that is concatenated with produced bounding box clauses.
    -t  => Rule tag applied to all generated rules.    
    -m  => Limit generated rule length to allow other rule elements to be added at a later time. 
    -p  => Generate profile_bounding_box rule clauses. 
    -b  => Generate bounding_box rule clauses.
    
    Output options:
    -f  => File name to write rules to. (defaults to geo-rules.json)
    -d  => Write rules as simple text for copying/pasting into console.gnip.com Rules user-interface.
    
    -h => Show parameter documentaton.


#### Dashboard output

-w -105.45 -e -104.56 -n 40.58 -s 39.9 -b -t "geo-frontrange" -r "flood OR storm OR rain" -f "geo-frontrange.json" 
```
{
  "rules": [
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-105.45000 39.90000 -105.00000 40.25000] OR bounding_box:[-105.00000 39.90000 -104.56000 40.25000] OR bounding_box:[-105.45000 40.25000 -104.98260 40.58000] OR bounding_box:[-104.98260 40.25000 -104.56000 40.58000])",
      "tag": "geo-frontrange"
    }
  ]
}
```


#### Dashboard output

-w -105.45 -e -104.56 -n 40.58 -s 39.9 -b -t "geo-frontrange" -r "flood OR storm OR rain" -f "geo-frontrange.json" -d

Since we added the "-d" parameter, a simple text file will be producted whose contents can easily be copied/pasted into the console. Note that the code will take the passed in file name and update it to *.txt.  So the resulting file is named geo-frontrange.txt and has these contents: 

```
(flood OR storm OR rain) (bounding_box:[-105.45000 39.90000 -105.00000 40.25000] OR bounding_box:[-105.00000 39.90000 -104.56000 40.25000] OR bounding_box:[-105.45000 40.25000 -104.98260 40.58000] OR bounding_box:[-104.98260 40.25000 -104.56000 40.58000])

```
