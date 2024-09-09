import numpy as np
import csv
from models.cell import GridCell
from sklearn.neighbors import BallTree
from sklearn.neighbors import KDTree
import pickle

def to_radians(coords):
    return np.radians(coords)

# def generate_grid():
#     columns_file = 'num_columns_per_row_10km_pruned2.csv'
#     num_cols_per_row = []

#     with open(columns_file, 'r') as col_file:
#         col_reader = csv.reader(col_file)
#         next(col_reader)  # Skip the header

#         for row in col_reader:
#             num_cols_per_row.append(int(row[1]))

#     num_rows = len(num_cols_per_row)

#     grid = [np.empty(num_cols_per_row[row_idx], dtype=object) for row_idx in range(num_rows)]

#     all_points = []
#     grid_cells = []
#     points_to_ind = {}
#     points_to_bathy = {}

#     with open('grid_points_with_bathymetry_10km_pruned2.csv', 'r') as file:
#         reader = csv.reader(file)
#         next(reader)  # Skip the header
#         o = 0
#         for row in reader:
#             lat, lon, is_land, bathymetry_depth,near_coastline,  row_idx, col_idx = float(row[0]), float(row[1]), int(row[2]), float(row[3]),row[4], int(row[5]), int(row[6])
#             if near_coastline == 'True':
#                 near_coastline = 1
#             else :
#                 near_coastline = 0
            
#             cell = GridCell(lat, lon, is_land, bathymetry_depth, near_coastline)
#             if not is_land:
#                 o += 1
            
#             grid[row_idx][col_idx] = cell

#             points_to_ind[(lat, lon)] = (row_idx, col_idx)
#             points_to_bathy[(lat, lon)] = bathymetry_depth
#             all_points.append([lat, lon])
#             grid_cells.append(cell)
#         print("Total Ocean cells: ", o)

#         with open('objects/num_cols_per_row2.pkl', 'wb') as f:
#             pickle.dump(num_cols_per_row, f)

#         with open('objects/all_points2.pkl', 'wb') as f:
#             pickle.dump(all_points, f)

#         with open('objects/grid_cells2.pkl', 'wb') as f:
#             pickle.dump(grid_cells, f)

#         with open('objects/points_to_ind2.pkl', 'wb') as f:
#             pickle.dump(points_to_ind, f)

#         with open('objects/grid2.pkl', 'wb') as f:
#             pickle.dump(grid, f)

#         with open('objects/points_to_bathy2.pkl', 'wb') as f:
#             pickle.dump(points_to_bathy, f)


#     return grid, all_points, grid_cells, points_to_ind, num_cols_per_row, points_to_bathy

#instead of creating we will be loading all the data from now

def generate_grid():
    num_cols_per_row = None
    all_points = None
    grid_cells = None 
    points_to_ind = None 
    grid = None 
    points_to_bathy = None

    files = ['num_cols_per_row.pkl','all_points.pkl', 'grid_cells.pkl', 'points_to_ind.pkl', 'grid.pkl', 'points_to_bathy.pkl']

    with open('objects/num_cols_per_row2.pkl', 'rb') as f:
        num_cols_per_row = pickle.load(f)

    with open('objects/all_points2.pkl', 'rb') as f:
        all_points = pickle.load(f)

    with open('objects/grid_cells2.pkl', 'rb') as f:
        grid_cells = pickle.load(f)

    with open('objects/points_to_ind2.pkl', 'rb') as f:
        points_to_ind = pickle.load(f)

    with open('objects/grid2.pkl', 'rb') as f:
        grid = pickle.load(f)

    with open('objects/points_to_bathy2.pkl', 'rb') as f:
        points_to_bathy = pickle.load(f)

    print("All files are loaded successfully...")

    return grid, all_points, grid_cells, points_to_ind, num_cols_per_row, points_to_bathy


def lat_lon_to_cartesian(lat, lon):
    lat_rad = np.radians(lat)
    lon_rad = np.radians(lon)
    x = np.cos(lat_rad) * np.cos(lon_rad)
    y = np.cos(lat_rad) * np.sin(lon_rad)
    z = np.sin(lat_rad)
    return np.array([x, y, z])

def build_KDTree(all_points):
    # all_points_cartesian = []
    # for i in all_points:
    #     all_points_cartesian.append(lat_lon_to_cartesian(i[0], i[1]))

    # Load the KDTree from the file
    kdtree = None
    with open('objects/kdtree_file2.pkl', 'rb') as f:
        kdtree = pickle.load(f)

    # kdtree = KDTree(all_points_cartesian)
    # with open('objects/kdtree_file2.pkl', 'wb') as f:
    #     pickle.dump(kdtree, f)
    return kdtree

def get_nearest_kdtree_node(kdtree, lat,lon):
    point = lat_lon_to_cartesian(lat, lon)
    dist, ind = kdtree.query([point])
    return dist, ind

def haversine(lat1, lon1, lat2, lon2):
    # Convert latitude and longitude from degrees to radians
    lat1, lon1, lat2, lon2 = map(np.radians, [lat1, lon1, lat2, lon2])
    
    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = np.sin(dlat / 2) ** 2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon / 2) ** 2
    c = 2 * np.arctan2(np.sqrt(a), np.sqrt(1 - a))
    
    # Distance in kilometers (Earth's radius = 6371 km)
    distance_km = 6371.0 * c
    return distance_km

def get_cost(dist,lat,lon,theta):
#     print(np.degrees(theta),end = " ")
#     print(dist,end = " ")
    wind_dir = np.cos(abs(theta - np.radians(0)))*10
#     print((wind_dir+10)/2,end = " ")
    cost = 0.9997*(dist*10) + 0.0003*(-1*(wind_dir+10)/2)
    cost1 = 1*(dist*10) + 0*((wind_dir+10)/2)
#     print(cost,cost1)
    return cost
