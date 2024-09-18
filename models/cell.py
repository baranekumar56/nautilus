class GridCell:
    def __init__(self, lat, lon, is_land, bathymetry_depth, near_coastline):
        self.lat = lat
        self.lon = lon
        self.is_land = is_land
        self.bathymetry_depth = bathymetry_depth
        self.near_coastline = near_coastline