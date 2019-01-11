## bounding-boxes (Ruby version)

A Ruby script for building bounding boxes. (Note that there is also a Python version for the initial prototype, more information [HERE](https://github.com/jimmoffitt/bounding-boxes/tree/master/pyBoundingBoxes)).

### References
+ http://en.wikipedia.org/wiki/Great_circle  <-- start here.
+ http://mathworld.wolfram.com/GreatCircle.html  <-- background math.
+ https://gist.github.com/1826175  <-- Python code for sphere distance.

### Introduction

A simple script for producing Tweet geotagged bounding boxes for large study areas. Bounding boxes have a 
25-mile per 'side' limit. So the script is designed to produce matrices of 25-mile bounding boxes for large areas such
as Coloroado.

#### Features
+ Supports Twitter [Profile Geo](https://developer.twitter.com/en/docs/tweets/enrichments/overview/profile-geo)  profile_bounding_box Operator.
     + '-g' for **bounding_box** operators that match on geo-tagged Tweets (completely) within the 25-mile rectangle.
     + '-p' for **Profile_bounding_box** operators that match on Tweets from an author with a public 'account home' (completely) within the 25-mile rectangle.
+ Enables business rule 'clauses' that can be ANDed with produced geo rules.
     + -r "weather OR snow OR rain OR contains:flood"
+ ORs together bounding box up to 1024 characters. These rules written in an atomic nature with surrounding parentheses.
+ Enables a character buffer to be specified so space can be reserved for future rule clauses.
     + -b 200    

#### Other details
+ All lat/long coordinates are in decimal degrees.
+ "Study area" refers to the area you want to generate (25-mile) bounding boxes for.
+ "Rule element" refers to a set of rule operators.  Rules we are addressing here typically have a 'business logic' element and a 'geographical' element.  

### Usage

The following parameters are used to specify the rules to be generated:
```
    Study area coordinates in decimal degrees (required):
    -w  => Western longitude.
    -e  => Eastern longitude. 
    -n  => North latitude.
    -s  => South latitude.
    
    Rule construction details:
    -r  => Rule value element that is concatenated with produced bounding box clauses.
    -t  => Rule tag applied to all generated rules.    
    -b  => Number of characters for a buffer to allow other rule elements to be added at a later time. 
    -p  => Generate profile_bounding_box rule clauses fornip
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


### Output Options

#### JSON output

By default rules will be written in JSON, as used by the Twitter PowerTrack Rules API and Search APIs. The default file name is geo-rules.json and that can be overridden with the '-f' parameter.  The output above provides an example of the JSON output.  

#### Dashboard output

By specifying that you want to enter rules by using the https://console.gnip.com dashboard, a simple text file will be producted whose contents can easily be copied/pasted into the console. This is indicated by including the '-d' (dashboard) parameter. 

```
-w -105.45 -e -104.56 -n 40.58 -s 39.9 -d
```

Note that the code will take the passed in file name and update it to *.txt.  So the resulting file is named geo-frontrange.txt and has these contents: 

```
(bounding_box:[-105.45000 39.90000 -105.00000 40.25000] OR bounding_box:[-105.00000 39.90000 -104.56000 40.25000] OR bounding_box:[-105.45000 40.25000 -104.98260 40.58000] OR bounding_box:[-104.98260 40.25000 -104.56000 40.58000])

```

### Command-line examples

#### Generating bounding_box: and/or profile_bounding_box: rule clauses

The '-p' option triggers the generation of profile_bounding_box: Operators for the Profile Geo enrichment. The '-g' option triggers the production of bounding box Operators for geo-tagged tweets, and is the default if neither option is specified. 

```
-p  => Generate profile_bounding_box rule clauses for Profile Geo enrichment. 

-g  => Generate bounding_box rule clauses for geo-tagged tweets (default if neither specified).

-p -g => Generates both.
```

So, this command-line:
    
```
bounding_boxes.rb -w -105.45 -e -105.40 -n 40.58 -s 40.5 -g -p
```

Produces:

```
{
  "rules": [
    {
      "value": "(bounding_box:[-105.450 40.500 -105.400 40.580] OR profile_bounding_box:[-105.450 40.500 -105.400 40.580])"
    }
  ]
}

```

#### Concatenating other rule elements to generated geographic rule element 

Additional rule clauses can be added on to the generated rules by using the '-r' option. This option enables you to add on other non-geographic rules clauses. If you do not provide opening and closing parentheses they are automatically added and these clauses are ANDed to the geographic clauses.

In the following example, the rule clauses "flood OR storm OR rain" are specified with the '-r' option:

```
bounding_boxes.rb -w -105.45 -e -104.56 -n 40.58 -s 39.9 -r "flood OR storm OR rain"
```

Produces:

```
{
  "rules": [
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-105.45000 39.90000 -105.00000 40.25000] OR bounding_box:[-105.00000 39.90000 -104.56000 40.25000] OR bounding_box:[-105.45000 40.25000 -104.98260 40.58000] OR bounding_box:[-104.98260 40.25000 -104.56000 40.58000])"
    }
  ]
}

```


#### Reserve a buffer for other rule clauses

You can reserve a 'character buffer' in the generated rules by using the '-b ###' parameter. The main purpose of this parameter is to reserve rule value characters for addition rule clauses.  It can also be used to affect how many bounding_box clauses get ORed together.  For example the average bounding_box operator requires about 60 characters (and 67 for profile_bounding_box Oerators). In the following example the 'base rule' element is specified as 'flood OR storm OR rain' for another 25 characters. So if you wanted one bounding_box clause per rule you could force that result by setting the reserved character buffer to 900:

```
bounding_boxes.rb -w -105.45 -e -104.56 -n 40.58 -s 39.9 -g -r "flood OR storm OR rain" -b 900
```

Produces:

```
{
  "rules": [
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-105.45000 39.90000 -105.00000 40.25000])"
    },
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-105.00000 39.90000 -104.56000 40.25000])"
    },
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-105.45000 40.25000 -104.98260 40.58000])"
    },
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-104.98260 40.25000 -104.56000 40.58000])"
    }
  ]
}
```

#### Adding tags to generated rules

Rule tags are useful for segregating rules into multiple sets. Rule tags come in handy when developing multiple sets of geographic rules for different areas.  The following command-line sets the rule tag to 'geo_front_range': 

```
bounding_boxes.rb -w -105.45 -e -104.56 -n 40.58 -s 39.9 -g -r "flood OR storm OR rain" -t "geo_front_range"
```

Produces:

```
{
  "rules": [
    {
      "value": "(flood OR storm OR rain) (bounding_box:[-105.45000 39.90000 -105.00000 40.25000] OR bounding_box:[-105.00000 39.90000 -104.56000 40.25000] OR bounding_box:[-105.45000 40.25000 -104.98260 40.58000] OR bounding_box:[-104.98260 40.25000 -104.56000 40.58000])",
      "tag": "geo_front_range"
    }
  ]
}
```

Here is an example set of command-lines for generating separate sets of bounding_box and profile_bounding_box rules for different areas:

```
bounding_boxes.rb -w -87.8 -e -87.4 -n 42.0 -s 41.6 -g -p -r "flood OR storm OR rain" -t "geo_chicago"
bounding_boxes.rb -w -118.4 -e -118.0 -n 34.2 -s 33.8 -g -p -r "flood OR storm OR rain" -t "geo_los_angeles"
bounding_boxes.rb -w -71.2 -e -70.8 -n 42.5 -s 42.1 -g -p -r "flood OR storm OR rain" -t "geo_boston"

```






