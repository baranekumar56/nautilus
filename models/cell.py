class GridCell:
    def __init__(self, lat, lon, is_land, bathymetry_depth):
        self.lat = lat
        self.lon = lon
        self.is_land = is_land
        self.bathymetry_depth = bathymetry_depth
