import numpy as np
import csv
from models.cell import GridCell
from sklearn.neighbors import BallTree
from sklearn.neighbors import KDTree
import pickle
def to_radians(coords):
    return np.radians(coords)


# For initially generating the object files

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
# w_grid = None

def generate_grid():
    num_cols_per_row = None
    all_points = None
    grid_cells = None 
    points_to_ind = None 
    grid = None 
    points_to_bathy = None
    wgrid = None

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
    with open('objects/weather_grid.pkl','rb') as f:
        wgrid = pickle.load(f)

    # w_grid = wgrid
    print("All files are loaded successfully...")

    return grid, all_points, grid_cells, points_to_ind, num_cols_per_row, points_to_bathy, wgrid


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


def get_cost(row,col,ship_heading,time,wgrid):
    time = int(time)
    time = time % 24
    wthr_obj = wgrid[row][col]
    wave_height = wthr_obj.Thgt[time]
    wave_period = wthr_obj.Tper[time]
    wave_direction = wthr_obj.Tdir[time]
    speed =  5 * wave_height**2 /wave_period
    dir = -1*(100/speed) * np.cos(np.radians(ship_heading - wave_direction))
    return speed+dir


import math

def haversine(lat1, lon1, lat2, lon2):
    # Radius of the Earth in km
    R = 6371.0

    # Convert degrees to radians
    lat1, lon1 = math.radians(lat1), math.radians(lon1)
    lat2, lon2 = math.radians(lat2), math.radians(lon2)

    # Haversine formula
    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a = math.sin(dlat / 2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # Distance in km
    return R * c

def calculate_bearing(lat1, lon1, lat2, lon2):
    # Convert latitude and longitude from degrees to radians
    lat1 = math.radians(lat1)
    lon1 = math.radians(lon1)
    lat2 = math.radians(lat2)
    lon2 = math.radians(lon2)

    # Compute the difference in longitudes
    dlon = lon2 - lon1

    # Calculate bearing using the formula
    x = math.sin(dlon) * math.cos(lat2)
    y = math.cos(lat1) * math.sin(lat2) - (math.sin(lat1) * math.cos(lat2) * math.cos(dlon))

    # atan2 to get the angle in radians and convert to degrees
    bearing = math.atan2(x, y)
    bearing = math.degrees(bearing)
    
    # Normalize the bearing to 0 - 360 degrees
    return (bearing + 360) % 360

def relative_angle_adjustment(current_lat, current_lon, neighbor_lat, neighbor_lon, target_lat, target_lon):
    # Get the bearings
    bearing_current_to_target = calculate_bearing(current_lat, current_lon, target_lat, target_lon)
    bearing_current_to_neighbor = calculate_bearing(current_lat, current_lon, neighbor_lat, neighbor_lon)
    
    # Relative angle between the two bearings
    relative_angle = abs(bearing_current_to_neighbor - bearing_current_to_target)
    
    # Adjust to fall within 0-180 degrees
    relative_angle = min(relative_angle, 360 - relative_angle)
    
    # Convert to radians for cosine calculation
    relative_angle_rad = math.radians(relative_angle)
    
    return math.cos(relative_angle_rad)

def adjusted_priorityy(current_lat, current_lon, neighbor_lat, neighbor_lon, target_lat, target_lon):
    # Calculate the new distance using the haversine formula
    new_distance = haversine(current_lat, current_lon, neighbor_lat, neighbor_lon)
    
    # Get the adjustment factor based on the relative angle
    cos_adjustment = relative_angle_adjustment(current_lat, current_lon, neighbor_lat, neighbor_lon, target_lat, target_lon)
    
    # Adjust the distance based on the cosine of the relative angle
    adjusted_distance = new_distance * (1 + cos_adjustment)
    
    # Calculate the heuristic (haversine between neighbor and end cell)
    heuristic = haversine(neighbor_lat, neighbor_lon, target_lat, target_lon)
    
    # New priority is heuristic + adjusted distance
    return heuristic + adjusted_distance


def adjusted_priority(lat1, lon1, lat2, lon2, goal_lat, goal_lon):
    # Calculate the bearing from the current node to the neighbor
    bearing_current_to_neighbor = calculate_bearing(lat1, lon1, lat2, lon2)
    
    # Calculate the bearing from the neighbor to the goal
    bearing_neighbor_to_goal = calculate_bearing(lat2, lon2, goal_lat, goal_lon)
    
    # Compute the relative angle between the two bearings
    relative_angle = abs(bearing_current_to_neighbor - bearing_neighbor_to_goal)
    
    # Normalize the relative angle to be between 0 and 180 degrees
    if relative_angle > 180:
        relative_angle = 360 - relative_angle
    
    # Convert the relative angle to radians
    relative_angle_rad = math.radians(relative_angle)
    
    # Apply the cosine adjustment to the distance
    distance = haversine(lat1, lon1, lat2, lon2)
    adjusted_distance = distance * (1 - 0.5 * (1 - math.cos(relative_angle_rad)))
    
    # Calculate the heuristic (distance from neighbor to goal)
    heuristic = haversine(lat2, lon2, goal_lat, goal_lon)
    
    # Priority is the new adjusted distance plus heuristic
    return adjusted_distance + heuristic

def calculate_bearing(lat1, lon1, lat2, lon2):
    # Convert latitude and longitude from degrees to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)
    
    # Compute the bearing
    d_lon = lon2_rad - lon1_rad
    x = math.sin(d_lon) * math.cos(lat2_rad)
    y = math.cos(lat1_rad) * math.sin(lat2_rad) - math.sin(lat1_rad) * math.cos(lat2_rad) * math.cos(d_lon)
    
    initial_bearing = math.atan2(x, y)
    
    # Convert bearing from radians to degrees
    initial_bearing_deg = math.degrees(initial_bearing)
    
    # Normalize the bearing to be within 0 to 360 degrees
    compass_bearing = (initial_bearing_deg + 360) % 360
    return compass_bearing

