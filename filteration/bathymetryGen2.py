import numpy as np
import csv
import netCDF4 as nc
from shapely.geometry import Point
from shapely.ops import nearest_points
import geopandas as gpd
from geopy.distance import geodesic

GRID_CELL_SIZE_KM = 10
EXCLUSION_RADIUS_KM = 22  # 22 km exclusion zone

# Reverse the lat_range to start from the northernmost latitude
lat_range = np.arange(-35, 30, GRID_CELL_SIZE_KM / 111.32)[::-1]

# Paths to files
points_file = 'grid_points_with_bathymetry_10km_pruned2.csv'
columns_file = 'num_columns_per_row_10km_pruned2.csv'  # File to store the number of columns for each row

# Load the GEBCO netCDF file
gebco_file_path = 'C:/Desktop/gebco_2024_sub_ice_topo/GEBCO_2024_sub_ice_topo.nc'
dataset = nc.Dataset(gebco_file_path)

# Load the Natural Earth coastline shapefile
coastline_file = 'projectmaterials/natural-earth-vector-master/10m_physical/ne_10m_coastline.shp'
coastlines = gpd.read_file(coastline_file)

# Combine all coastlines into a single geometry using union_all()
coastline_union = coastlines.geometry.unary_union
count = 0

with open(points_file, 'w', newline='') as points_csv, open(columns_file, 'w', newline='') as columns_csv:
    points_writer = csv.writer(points_csv)
    columns_writer = csv.writer(columns_csv)
    

    # Write headers
    points_writer.writerow(['Latitude', 'Longitude', 'Is_Land', 'Bathymetry_Depth','Near_Coastline', 'Row', 'Column'])
    columns_writer.writerow(['Row', 'Num_Columns'])
    
    rowNum = 0

    lats = dataset.variables['lat'][:]
    lons = dataset.variables['lon'][:]

    for lat in lat_range:
        # Calculate dynamic lon_range for each latitude
        lon_range = np.arange(26, 130, GRID_CELL_SIZE_KM / (111.32 * np.cos(np.radians(lat))))
        valid_points = []
        
        colNum = 0
        for lon in lon_range:
            print(len(dataset.variables['lat']))
            lat_idx = np.searchsorted(lats, lat)
            lon_idx = np.searchsorted(lons, lon)
            bathymetry_depth = dataset.variables['elevation'][lat_idx, lon_idx]
            
            is_land = bathymetry_depth >= 0  # Typically, bathymetry values >= 0 indicate land
            
            # Create a point for the current cell
            current_point = Point(lon, lat)
            
            # Find the nearest point on the coastline
            nearest_geom = nearest_points(current_point, coastline_union)[1]
            nearest_point = (nearest_geom.y, nearest_geom.x)
            
            # Calculate the distance to the nearest coastline point
            distance_to_coastline = geodesic((lat, lon), nearest_point).km
            # Exclude the cell if it's within the exclusion radius
            if distance_to_coastline > EXCLUSION_RADIUS_KM:
                valid_points.append([lat, lon, 1 if is_land else 0, bathymetry_depth,False,  rowNum, colNum])
                colNum += 1
            
            else:
                valid_points.append([lat, lon, 1 if is_land else 0, bathymetry_depth,True,  rowNum, colNum])
                colNum += 1

        
        # Write valid points to CSV
        for point in valid_points:
            points_writer.writerow(point)
        
        

        # Write the number of valid columns for the current row to the CSV
        columns_writer.writerow([rowNum, colNum])
        
        rowNum += 1

print(f"Grid points with bathymetry, land/sea status, and exclusion applied have been saved to {points_file}.")
print(f"Updated number of columns per row has been saved to {columns_file}.")
print("Excluded count: ", count)