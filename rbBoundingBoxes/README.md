##bounding-boxes (Ruby version)

A Ruby script for building bounding boxes.

###Introduction

A simple script for producing Gnip bounding boxes for a study area.  Gnip bounding boxes have a 
25-mile per 'side' limit.  So the script is used to produce 25-mile bounding boxes for a large area such
as Coloroado.

####Features
+ Supports Gnip Profile Geo profile_bounding_box Operator.
+ Enables a business rules 'element' that can be ANDed with produced geo rules.
+ ORs together bounding box up to 1024 characters. These rules written in an atomic nature with surrounding parentheses.
+ Enables a character buffer to be specified so space can be reserved for future rule elements.


####Other details
+ All lat/long coordinates are in decimal degrees.
+ "Study area" refers to the area you want to generate (25-mile) bounding boxes for.
+ "Rule element" refers to a set of rule operators.  Rules we are addressing here typically have a 'business logic' element and a 'geographical' element.  


###Usage

The following parameters are used to specify the rule you are after:
```
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
    -b  => Generate bounding_box rule clauses (default if neither specified).
    
    Output options:
    -f  => File name to write rules to (defaults to geo-rules.json).
    -d  => Write rules as simple text for copying/pasting into console.gnip.com Rules user-interface.
    
    -h => Show parameter documentaton.
```


The most basic call would look like:
```
ruby bounding_boxes.rb -w -105.45 -e -104.56 -n 40.58 -s 39.9 
```

This would produce a 'geo_rules.json' file with the following contents:

```
{
  "rules": [
    {
      "value": " (bounding_box:[-105.45000 39.90000 -105.00000 40.25000] OR bounding_box:[-105.00000 39.90000 -104.56000 40.25000] OR bounding_box:[-105.45000 40.25000 -104.98260 40.58000] OR bounding_box:[-104.98260 40.25000 -104.56000 40.58000])"
    }
  ]
}
```


###Output Options

#### JSON output

By default rules will be written in JSON, as used by the Gnip Rules API. 

```
-w -105.45 -e -104.56 -n 40.58 -s 39.9 -b -t "geo-frontrange" -r "flood OR storm OR rain" -f "geo-frontrange.json" 
```



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

By specifying that you want to enter rules by using the console.gnip dashboard, a simple text file will be producted whose contents can easily be copied/pasted into the console. This is indicated by including the '-d' (dashboard) parameter. 

Note that the code will take the passed in file name and update it to *.txt.  So the resulting file is named geo-frontrange.txt and has these contents: 

-w -105.45 -e -104.56 -n 40.58 -s 39.9 -b -t "geo-frontrange" -r "flood OR storm OR rain" -f "geo-frontrange.json" -d

```
(flood OR storm OR rain) (bounding_box:[-105.45000 39.90000 -105.00000 40.25000] OR bounding_box:[-105.00000 39.90000 -104.56000 40.25000] OR bounding_box:[-105.45000 40.25000 -104.98260 40.58000] OR bounding_box:[-104.98260 40.25000 -104.56000 40.58000])

```



###Command-line examples:

####Maximum characters for generated rules

The maximum length of the bounding_box element can be specified by using the '-m ###' parameter. The main purpose of this parameter is to reserve rule value characters for addition rule elements.  It can also be used to affect how many bounding_box claused get ORed together.  For example the average bounding_box operator requires about 60 characters (and 67 for profile_bounding_box Oerators). In the following example the 'base rule' element is specified as 'flood OR storm OR rain' for another 25 characters. So if you wanted one bounding_box clause per rule you could force that result by setting the maximum length of the genereated rules to 100 characaters:

-m 100

```
bounding_boxes.rb -w -105.45 -e -104.56 -n 40.58 -s 39.9 -m 100
```

Produces:

```
{
  "rules": [
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-105.45000 39.90000 -105.00000 40.25000])",
      "tag": "geo-frontrange"
    },
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-105.00000 39.90000 -104.56000 40.25000])",
      "tag": "geo-frontrange"
    },
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-105.45000 40.25000 -104.98260 40.58000])",
      "tag": "geo-frontrange"
    },
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-104.98260 40.25000 -104.56000 40.58000])",
      "tag": "geo-frontrange"
    }
  ]
}
```



