include Math

class GnipGlobe
    PI = Math::PI
    EARTH_RADIUS_MI = 3963.1900


    def self.deg2Rad(degree)
        degree * PI / 180
    end


    def self.distance_in_mile(pt1, pt2)
        return self.distance_in_radius(pt1, pt2) * EARTH_RADIUS_MI
    end

    def self.distance_in_radius(pt1, pt2)

        dlat = deg2Rad(pt2.south - pt1.south)
        dlong = deg2Rad(pt2.west - pt1.west)

        a = sin(dlat/2)**2 +
            cos(deg2Rad(pt1.south)) * cos(deg2Rad(pt2.south)) *
                sin(dlong/2)**2
        c = 2 * atan2(sqrt(a), sqrt(1-a))

        return c
    end

end