###bounding-boxes (Ruby version)

A Ruby script for building bounding boxes.

A simple script for producing Gnip bounding boxes for a study area.  Gnip bounding boxes have a 
25-mile per 'side' limit.  So the script is used to produce 25-mile bounding boxes for a large area such
as Coloroado.


+ Supports Gnip Profile Geo profile_bounding_box Operator.
+ Enables a business rules 'element' that can be ANDed with produced geo rules.
+ ORs together bounding box up to 1024 characters. These rules written in an atomic nature with surrounding parentheses.
+ Enables a character buffer to be specified so space can be reserved for future rule elements.



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

```
(flood OR storm OR rain) (bounding_box:[-105.45000 39.90000 -105.00000 40.25000] OR bounding_box:[-105.00000 39.90000 -104.56000 40.25000] OR bounding_box:[-105.45000 40.25000 -104.98260 40.58000] OR bounding_box:[-104.98260 40.25000 -104.56000 40.58000])

```
