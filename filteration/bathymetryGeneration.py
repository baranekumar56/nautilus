import numpy as np
import csv
import netCDF4 as nc

GRID_CELL_SIZE_KM =  1

# Reverse the lat_range to start from the northernmost latitude
lat_range = np.arange(-35, 30, GRID_CELL_SIZE_KM / 111.32)[::-1]

# Paths to files
points_file = 'grid_points_with_bathymetry_updated_with_1km.csv'
columns_file = 'num_columns_per_row_1km.csv'  # File to store the number of columns for each row

# Load the GEBCO netCDF file
gebco_file_path = 'C:/Desktop/gebco_2024_sub_ice_topo/GEBCO_2024_sub_ice_topo.nc'
dataset = nc.Dataset(gebco_file_path)

latitudes = dataset.variables['lat']
longitudes = dataset.variables['lon']
bathymetry = dataset.variables['elevation']

with open(points_file, 'w', newline='') as points_csv, open(columns_file, 'w', newline='') as columns_csv:
    points_writer = csv.writer(points_csv)
    columns_writer = csv.writer(columns_csv)
    
    # Write headers
    points_writer.writerow(['Latitude', 'Longitude', 'Is_Land', 'Bathymetry_Depth', 'Row', 'Column'])
    columns_writer.writerow(['Row', 'Num_Columns'])
    
    rowNum = 0

    for lat in lat_range:
        # Calculate dynamic lon_range for each latitude
        lon_range = np.arange(26, 130, GRID_CELL_SIZE_KM / (111.32 * np.cos(np.radians(lat))))
        num_cols = len(lon_range)
        
        # Write the number of columns for the current row to the CSV
        columns_writer.writerow([rowNum, num_cols])
        
        colNum = 0
        for lon in lon_range:
            lat_idx = np.searchsorted(latitudes[:], lat)
            lon_idx = np.searchsorted(longitudes[:], lon)
            bathymetry_depth = bathymetry[lat_idx, lon_idx]
            
            is_land = bathymetry_depth >= 0  # Typically, bathymetry values >= 0 indicate land
            
            points_writer.writerow([lat, lon, 1 if is_land else 0, bathymetry_depth, rowNum, colNum])
            colNum += 1
        
        rowNum += 1

print(f"Grid points with bathymetry and land/sea status have been saved to {points_file}.")
print(f"Number of columns per row have been saved to {columns_file}.")
