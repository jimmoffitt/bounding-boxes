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

    Need to be able to inspect a shapefile and build the appropriate bounding boxes.

    Supported units:
        math: meters
        distance: miles, kilometers, meters, feet.

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

  def initialize()
  end

  #CLASS constants
  PI = 3.1415926535
  RAD_PER_DEG = 0.017453293  #  PI/180
  R_MILES = 3956           # radius of the great circle in miles
  R_KM = 6371              # radius in kilometers...some algorithms use 6367
  R_FEET = R_MILES * 5282   # radius in feet
  R_METERS = R_KM * 1000    # radius in meters


  def to_s
    "Gnip Globe object: version " + @version
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

    @distances = Hash.new

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

    dMi = R_MILES * c          # delta between the two points in miles
    dKm = R_KM * c             # delta in kilometers
    dFeet = R_FEET * c         # delta in feet
    dMeters = R_METERS * c     # delta in meters

    @distances["mi"] = dMi
    @distances["km"] = dKm
    @distances["ft"] = dFeet
    @distances["m"] = dMeters

    return @distances

  end

  def getHaversineDistance(pt1,pt2)
    lon1 = deg2Rad(pt1.x)
    lat1 = deg2Rad(pt1.y)
    lon2 = deg2Rad(pt2.x)
    lat2 = deg2Rad(pt2.y)

    2 * R_KM * asin(sqrt(sin((lat2-lat1)/2)**2 + cos(lat1) * cos(lat2) * sin((lon2 - lon1)/2)**2))

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

def test_haversine


  lon1 = -86.67
  lat1 =  36.12

  lat2 =   33.94
  lon2 =  -118.40

  #2887.2599506071106

  '''
  lon1 = -104.88544
  lat1 = 39.06546

  lon2 = -104.80
  lat2 = lat1
  '''

  pt1 = Point.new(lon1,lat1)
  pt2 = Point.new(lon2,lat2)

  gg = GnipGlobe.new()

  p gg.getHaversineDistance(pt1,pt2)

  @distances = Hash.new
  @distances = gg.getHaversineDistance2(pt1,pt2)


  puts "the distance from  #{lat1}, #{lon1} to #{lat2}, #{lon2} is:"
  puts "#{@distances['mi']} mi"
  puts "#{@distances['km']} km"
  puts "#{@distances['ft']} ft"
  puts "#{@distances['m']} m"

  if ( @distances['km'].to_s.match(/7\.376*/) != nil )
    puts "Test: Success"
  else
    puts "Test: Failed"
  end

end


#UNIT TESTING...
test_haversine