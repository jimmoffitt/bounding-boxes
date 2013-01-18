=begin

  So far, a random collection of geographic routines.

    Decimal Degrees only
    GCS NAD83
    #TODO: Datum details.
    #TODO: Projection details.

     Started with sphere-surface calculations such as:
        * distance between two points.
        * the decimal degree offset from a single point:
            Example:  the DD location 25 miles

    Operates on these fundamental objects:
        * Point

    Future: Need to be able to inspect a shapefile and build the appropriate bounding boxes.

    Supported units:
        (internal) math: meters
        (output) distance: miles, kilometers, meters, feet.

    Fundamental test locations: four hemispheres, two intersections and two poles.

    Some References:
            http://en.wikipedia.org/wiki/Great_circle  <-- start here.
            http://mathworld.wolfram.com/GreatCircle.html  <-- background math.
            http://www.codecodex.com/wiki/Calculate_distance_between_two_points_on_a_globe
                    ^ Ruby code for sphere distance. (code currently below)

            http://www.movable-type.co.uk/scripts/gis-faq-5.1.html

        Haversine algorithm:
          http://mathforum.org/library/drmath/view/51879.html
          http://www.movable-type.co.uk/scripts/latlong.html
          http://en.wikipedia.org/wiki/Haversine_formula

          http://rosettacode.org/wiki/Haversine_formula <-- examples in (nearly) any language.

=end

include Math

#Simple class for storing a point.
class Point
  attr_accessor :x, :y, :z, :name, :memberOf, :units, :unitsz
  #X position of point.  East/West, longitude, horizontal.
  #Y position of point.  North/South, latitude, vertical.
  #Z position of point.  Point elevation.  Point in time.
  #A name can be associated with point.  Site name for example.
  #Point can be a member of something.
  #Points X,Y values share a unit type.  z can too, but not always...
      #If X,Y need different units, this class should be subclasses and extended.
  #Z attribute can have a different (and almost assumed).

  def initialize(x,y)
    @x, @y = x,y
  end

  def to_s
    s =  "(#@x,#@y)"
    if not @name.nil?
      s = s + ' with name ' + @name
    end
  end

  '''
  def x  #Get x.
    @x
  end
  def x=(value)
    @x = value
  end
  '''
end #of Point class.


class GnipGlobe
  @version = '0.01'
  attr_accessor :latLongUnit, :distanceUnit, :type, :radius

  def initialize()
    @type = "perfect circle" #ellipsoid
    @latLongUnit = "dd"
    @distanceUnit = "m"
  end

  #CLASS constants
  PI = 3.1415926535
  RAD_PER_DEG = 0.017453293  #  PI/180
  EARTH_RADIUS_METERS = 5282000


  def to_s
    "Gnip Globe object: version " + @version
  end

  def convertDistance(value,unit,toUnit)
    @KM_IN_MILE = 1.609344
    @METER_IN_FOOT = 0.3048
    @METER_IN_MILE = 1609.344

    if unit = toUnit then
      return unit
    end

    if units == "m" then
      if toUnits == "mi" then
        return value / @METER_IN_MILE
      end
      if toUnits == "ft" then
        return value / @METER_IN_FOOT
      end
    end
  end


  '''
  '''
  def getGlobeDistance(pt1,pt2)
    return getGreatDistance(pt1,pt2)
  end


  '''
     Returns Great Circle distance between two points.
  '''
  def getGreatDistance(pt1,pt2)

  end

  '''
    Returns Haversine distance between two points.
  '''
  def getHaversineDistance2(pt1,pt2)

    lon1 = pt1.x
    lat1 = pt1.y
    lon2 = pt2.x
    lat2 = pt2.y

    dlon = lon2 - lon1
    dlat = lat2 - lat1

    dlon_rad = dlon * RAD_PER_DEG
    dlat_rad = dlat * RAD_PER_DEG

    lat1_rad = lat1 * RAD_PER_DEG
    lon1_rad = lon1 * RAD_PER_DEG

    lat2_rad = lat2 * RAD_PER_DEG
    lon2_rad = lon2 * RAD_PER_DEG

    # puts "dlon: #{dlon}, dlon_rad: #{dlon_rad}, dlat: #{dlat}, dlat_rad: #{dlat_rad}"

    a = (sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))

    distance = EARTH_RADIUS_METERS * c
  end

  def getHaversineDistance(pt1,pt2)
    lon1 = deg2Rad(pt1.x)
    lat1 = deg2Rad(pt1.y)
    lon2 = deg2Rad(pt2.x)
    lat2 = deg2Rad(pt2.y)

    2 * EARTH_RADIUS_METERS/1000 * asin(sqrt(sin((lat2-lat1)/2)**2 + cos(lat1) * cos(lat2) * sin((lon2 - lon1)/2)**2))
  end

  def deg2Rad(degree)
    degree * PI / 180
  end

  '''
    Return "linear" distance
  '''
  def getDistance(p1,p2)
  end
end #of GnipGlobe

#-----------------------------------------
#Usage examples and unit testing:
#-----------------------------------------

if __FILE__ == $0

  lon1 = -86.67
  lat1 =  36.12
  pt1 = Point.new(lon1,lat1)
  pt2 = Point.new(-118.40,33.94)

  '''
  lon1 = -104.88544
  lat1 = 39.06546
  lon2 = -104.80
  lat2 = lat1
  '''

  gg = GnipGlobe.new()
  p "Simplified circle algoritm: " + gg.getHaversineDistance(pt1,pt2).to_s + " meters."
  distance = gg.getHaversineDistance2(pt1,pt2)
  p "Haversine version: " + distance.to_s + " meters."

  @distances = Hash.new
  @distances["m"] = gg.convertDistance(distance,"m","m")
  @distances["mi"] = gg.convertDistance(distance,"m","mi")
  @distances["km"] = distance * 1000
  @distances["ft"] = gg.convertDistance(distance,"m","ft")

  puts "the distance from  #{pt1.y}, #{pt1.x} to #{pt2.y}, #{pt2.x} is:"
  puts "#{@distances['mi']} mi"
  puts "#{@distances['km']} km"
  puts "#{@distances['ft']} ft"
  puts "#{@distances['m']} m"

end