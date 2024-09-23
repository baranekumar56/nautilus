import csv
import math
import numpy as np
from gridGeneration.gridGenUtils import *
from sklearn.neighbors import BallTree
from models.cell import GridCell
import heapq
import time

GRID_CELL_SIZE_KM = 10
EARTH_RADIUS_KM = 6371.0


class Grid:
    use_a_star = False
    grid = None
    all_points = []
    grid_cells = []
    point_to_ind = {}
    kdtree = None
    num_cols_per_row = []
    coord_to_bathy = {}
    wgrid = None
    def __init__(self) -> None:
        # setting up the grid 
        #doing all the reqired things like setting up the grid and creating neighbour trees and search indexes
        t = time.time()
        self.grid,self.all_points, self.grid_cells, self.point_to_ind, self.num_cols_per_row, self.coord_to_bathy,self.wgrid  = generate_grid()

        #setting up the nearest neighbour tree
        # self.ball_tree = set_up_nearest_neighbour_tree(self.all_points)
        self.kdtree = build_KDTree(self.all_points)
        p = time.time()

        print("Time took to load :", p - t)

    def get_nearest_cell(self, lat, lon):

        distance, index = get_nearest_kdtree_node(self.kdtree, lat, lon)
        return self.grid_cells[index[0][0]] , distance[0][0] * EARTH_RADIUS_KM
    

    def dijkstra(self, start_lat, start_lon, end_lat, end_lon):
        # Find the nearest start and end cells
        start_cell, _ = self.get_nearest_cell(start_lat, start_lon)
        end_cell, _ = self.get_nearest_cell(end_lat, end_lon)

        start = (start_cell.lat, start_cell.lon)
        end = (end_cell.lat, end_cell.lon)
        print(start)
        print(end)
        # Get indices of start and end cells
        start_idx = self.point_to_ind.get(start, None)
        end_idx = self.point_to_ind.get(end, None)

        if start_idx is None or end_idx is None:
            raise ValueError("Start or end cell not found in grid.")

        start_row, start_col = start_idx
        end_row, end_col = end_idx

        print(self.grid[start_row][start_col].is_land)
        print(self.grid[end_row][end_col].is_land)

        # Initialize distances and previous cell tracking
        num_rows = len(self.grid)
        distances = np.full((num_rows, max(self.num_cols_per_row)), np.inf)
        distances[start_row][start_col] = 0
        prev = np.full((num_rows, max(self.num_cols_per_row)), None)

        priority_queue = []
        heapq.heappush(priority_queue, (0, (start_row, start_col)))
        traversed = []
        while priority_queue:
            current_distance, (row, col) = heapq.heappop(priority_queue)

            traversed.append((self.grid[row][col].lat,self.grid[row][col].lon))
            # Check if we reached the goal
            if(row == end_row and col == end_col):
                break

            # if current_distance > distances[row][col]:
            #     continue

            # Consider all 8 possible directions
            directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
            for dr, dc in directions:
                r, c = row + dr, col + dc
                if 0 <= r < num_rows and 0 <= c < self.num_cols_per_row[r]:
                    neighbor = self.grid[r][c]
                    if neighbor is not None and not neighbor.is_land and neighbor.bathymetry_depth <= -20 and not neighbor.near_coastline:
                        distance = haversine(self.grid[row][col].lat, self.grid[row][col].lon,neighbor.lat, neighbor.lon)

                        # distance = abs(self.grid[row][col].lat - self.grid[r][c].lat) * 111.32 + abs(self.grid[row][col].lon - self.grid[r][c].lon) * 111.32

                        new_distance = current_distance + distance
                        if new_distance < distances[r][c]:
                            distances[r][c] = new_distance
                            prev[r][c] = (row, col)
                            heapq.heappush(priority_queue, (new_distance, (r, c)))

        # Reconstruct the shortest path
        path = [] 
        step = (end_row, end_col)
        while step is not None:
            path.append(step)
            step = prev[step[0]][step[1]]
        path.reverse()
        print("size:", path.__len__())
        print("Total Distance Taken:", distances[end_row][end_col])
        # Convert indices to lat/lon for path
        path_lat_lon = [(self.grid[row][col].lat, self.grid[row][col].lon) for row, col in path]

        return (path_lat_lon,traversed)

    def a_star(self, start_lat, start_lon, end_lat, end_lon,initial_time,initial_speed,flag):

        # Find the nearest start and end cells
        start_lat = float(start_lat)
        start_lon = float(start_lon)
        end_lat = float(end_lat)
        end_lon = float(end_lon)
        initial_speed = float(initial_speed)
        print(initial_speed)

        start_cell, dis = self.get_nearest_cell(start_lat, start_lon)
        end_cell, dis = self.get_nearest_cell(end_lat, end_lon)
        print("Start Cell is Land:", start_cell.is_land)
        print("End Cell is Land:", end_cell.is_land)

        # print(start_cell.near_coastline)

        start = (start_cell.lat, start_cell.lon)
        end = (end_cell.lat, end_cell.lon)
        print(start, end)

        # directions = [
        #     (2, 0),     # 0° (East)
        #     (2, 1),     # 22.5°
        #     (2, 2),     # 45° (Northeast)
        #     (1, 2),     # 67.5°
        #     (0, 2),     # 90° (North)
        #     (-1, 2),    # 112.5°
        #     (-2, 2),    # 135° (Northwest)
        #     (-2, 1),    # 157.5°
        #     (-2, 0),    # 180° (West)
        #     (-2, -1),   # 202.5°
        #     (-2, -2),   # 225° (Southwest)
        #     (-1, -2),   # 247.5°
        #     (0, -2),    # 270° (South)
        #     (1, -2),    # 292.5°
        #     (2, -2),    # 315° (Southeast)
        #     (2, -1)     # 337.5°
        # ]
        directions = [
        (0, 3),      # 0° (East)
        (1, 3),      # 15°
        (2, 3),      # 30°
        (3, 3),      # 45° (Northeast)
        (3, 2),      # 60°
        (3, 1),      # 75°
        (3, 0),      # 90° (North)
        (3, -1),     # 105°
        (3, -2),     # 120°
        (3, -3),     # 135° (Northwest)
        (2, -3),     # 150°
        (1, -3),     # 165°
        (0, -3),     # 180° (West)
        (-1, -3),    # 195°
        (-2, -3),    # 210°
        (-3, -3),    # 225° (Southwest)
        (-3, -2),    # 240°
        (-3, -1),    # 255°
        (-3, 0),     # 270° (South)
        (-3, 1),     # 285°
        (-3, 2),     # 300°
        (-3, 3),     # 315° (Southeast)
        (-2, 3),     # 330°
        (-1, 3)      # 345°
        ]

        angles = np.radians(np.arange(0,360,15))
       
        start_idx = self.point_to_ind.get(start, None)
        end_idx = self.point_to_ind.get(end, None)

        if start_idx is None or end_idx is None:
            raise ValueError("Start or end cell not found in grid.")

        start_row, start_col = start_idx
        print(start_idx)
        print(end_idx)
        end_row, end_col = end_idx
        # Initialize distances, heuristic, and previous cell tracking
        num_rows = len(self.grid)
        distances = np.full((num_rows, max(self.num_cols_per_row)), np.inf)
        distances[start_row][start_col] = 0
        prev = np.full((num_rows, max(self.num_cols_per_row)), None)

        # Priority queue (min-heap) with (priority, (row, col))
        priority_queue = []
        heapq.heappush(priority_queue, (0, (start_row, start_col,0)))
        end_time = 0
        while priority_queue:
            current_priority, (row, col,curr_time) = heapq.heappop(priority_queue)

            if haversine(self.grid[row][col].lat,self.grid[row][col].lon, end_lat, end_lon) < 30:
                end_row = row
                end_col = col
                break

            if (row == end_row and col == end_col):
                break


            for i,(dr, dc) in enumerate(directions):
                r, c = row + dr, col + dc
                if 0 <= r < num_rows and 0 <= c < self.num_cols_per_row[r]:
                    neighbor = self.grid[r][c]
                    if neighbor is not None and not neighbor.is_land and neighbor.bathymetry_depth <= -20 and not neighbor.near_coastline:
                        # Calculate actual distance between current cell and neighbor
                        distance = haversine(
                            self.grid[row][col].lat, self.grid[row][col].lon,
                            neighbor.lat, neighbor.lon
                        )
                        dtime = (distance/initial_speed) *(5/18)
                        new_distance = distances[row][col] + distance
                        heuristic = haversine(neighbor.lat, neighbor.lon, self.grid[end_row][end_col].lat, self.grid[end_row][end_col].lon)
                        priority = None
                        end_time = curr_time + dtime
                        cost = get_cost(r,c,angles[i],end_time,self.wgrid)
                        priority = 0.8*(heuristic + new_distance) + 0.2*(cost)
                        # priority =  get_cost(heuristic+new_distance,start_lat,end_lat,angles[i])
                        # priority = adjusted_priority(self.grid[row][col].lat,self.grid[row][col].lon, self.grid[r][c].lat, self.grid[r][c].lon, end_lat, end_lon)
                        
                        if new_distance < distances[r][c]:
                            distances[r][c] = new_distance
                            prev[r][c] = (row,col,end_time)
                            heapq.heappush(priority_queue, (priority, (r, c,end_time)))

        # Reconstruct the shortest path
        print("entT",end_time)
        end_time = int(end_time)
        wcell = self.wgrid[end_row][end_col]
        path_lat_lon = [[end[0],end[1],wcell.Thgt[(end_time + 1)%24],wcell.Tper[(end_time + 1)%24],wcell.Tdir[(end_time + 1)%24]]]
        s = (end_row, end_col,end_time)
        while s is not None:
            gcell = self.grid[s[0]][s[1]]
            wcell = self.wgrid[s[0]][s[1]]
            time = int(s[2])
            time = time % 24
            path_lat_lon.append((gcell.lat,gcell.lon,wcell.Thgt[time],wcell.Tper[time],wcell.Tdir[time]))
            s = prev[s[0]][s[1]]
        path_lat_lon.reverse()

        # Convert indices to lat/lon for path
        print("Total Distance Taken:", distances[end_row][end_col])
        return (path_lat_lon)

    # def have_path(self, start_lat, start_lon, end_lat, end_lon):
    #     start_cell, dis = self.get_nearest_cell(start_lat, start_lon)
    #     end_cell, dis = self.get_nearest_cell(end_lat, end_lon)
    #     print("Start Cell is Land:", start_cell.is_land)
    #     print("End Cell is Land:", end_cell.is_land)


    #     start = (start_cell.lat, start_cell.lon)
    #     end = (end_cell.lat, end_cell.lon)
    #     print(start, end)
    #     directions = [
    #     (0, 3),      # 0° (East)
    #     (1, 3),      # 15°
    #     (2, 3),      # 30°
    #     (3, 3),      # 45° (Northeast)
    #     (3, 2),      # 60°
    #     (3, 1),      # 75°
    #     (3, 0),      # 90° (North)
    #     (3, -1),     # 105°
    #     (3, -2),     # 120°
    #     (3, -3),     # 135° (Northwest)
    #     (2, -3),     # 150°
    #     (1, -3),     # 165°
    #     (0, -3),     # 180° (West)
    #     (-1, -3),    # 195°
    #     (-2, -3),    # 210°
    #     (-3, -3),    # 225° (Southwest)
    #     (-3, -2),    # 240°
    #     (-3, -1),    # 255°
    #     (-3, 0),     # 270° (South)
    #     (-3, 1),     # 285°
    #     (-3, 2),     # 300°
    #     (-3, 3),     # 315° (Southeast)
    #     (-2, 3),     # 330°
    #     (-1, 3)      # 345°
    #     ]
       
    #     start_idx = self.point_to_ind.get(start, None)
    #     end_idx = self.point_to_ind.get(end, None)

    #     if start_idx is None or end_idx is None:
    #         raise ValueError("Start or end cell not found in grid.")

    #     start_row, start_col = start_idx
    #     print(start_idx)
    #     print(end_idx)
    #     end_row, end_col = end_idx

    #     num_rows = len(self.grid)
    #     distances = np.full((num_rows, max(self.num_cols_per_row)), np.inf)
    #     distances[start_row][start_col] = 0
    #     prev = np.full((num_rows, max(self.num_cols_per_row)), None)

    #     priority_queue = []
    #     heapq.heappush(priority_queue, (0, (start_row, start_col)))

    #     while priority_queue:
    #         current_priority, (row, col) = heapq.heappop(priority_queue)

    #         if haversine(self.grid[row][col].lat,self.grid[row][col].lon, end_lat, end_lon) < 30:
    #             end_row = row
    #             end_col = col
    #             break

    #         if (row == end_row and col == end_col):
    #             break

    #         for i,(dr, dc) in enumerate(directions):
    #             r, c = row + dr, col + dc
    #             if 0 <= r < num_rows and 0 <= c < self.num_cols_per_row[r]:
    #                 neighbor = self.grid[r][c]
    #                 if neighbor is not None and not neighbor.is_land and neighbor.bathymetry_depth <= -20 and not neighbor.near_coastline:
    #                     distance = haversine(
    #                         self.grid[row][col].lat, self.grid[row][col].lon,
    #                         neighbor.lat, neighbor.lon
    #                     )
    #                     new_distance = distances[row][col] + distance
    #                     heuristic = haversine(neighbor.lat, neighbor.lon, self.grid[end_row][end_col].lat, self.grid[end_row][end_col].lon)
    #                     priority = heuristic
                        
    #                     if new_distance < distances[r][c]:
    #                         distances[r][c] = new_distance
    #                         prev[r][c] = (row, col)
    #                         heapq.heappush(priority_queue, (priority, (r, c)))

    #     # Reconstruct the shortest path
    #     path = []
    #     step = (end_row, end_col)
    #     while step is not None:
    #         path.append(step)
    #         step = prev[step[0]][step[1]]
    #     path.reverse()

    #     # Convert indices to lat/lon for path
    #     path_lat_lon = [(self.grid[row][col].lat, self.grid[row][col].lon) for row, col in path]

    #     print("Size of Path:", len(path))
    #     print("Total Distance Taken:", distances[end_row][end_col])
    #     return (path_lat_lon)

    # def isochrone(self, start_lat, start_lon, end_lat, end_lon):
    #     #going to the nearest bounding box

    #     dis, start= get_nearest_kdtree_node(self.kdtree, start_lat, start_lon)
    #     start = (self.all_points[start[0][0]])
    #     start = (start[0], start[1])
    #     dis, end = get_nearest_kdtree_node(self.kdtree, end_lat, end_lon)
    #     end = (self.all_points[end[0][0]])
    #     end = (end[0], end[1])

    #     if self.coord_to_bathy[start] >= -10 or self.coord_to_bathy[end] >= -10:
    #         print("Cant genreate map as it intersects land")
    #         return  []

    #     print(haversine(start[0], start[1],end[0], end[1] ))

    #     #constants
    #     DELTA_T = 1  # Time interval (hours)
    #     STEP_SIZE = 10  # Distance increment for generating waypoints (km)
    #     NUM_WAYPOINTS = 36  # Number of waypoints per isochrone
    #     WAYPOINTS_PER_SUBSECTOR = 1  # Number of closest waypoints to keep
    #     SUBSECTOR_COUNT = 3  # Number of subsectors on each side of the reference path
    #     SUBSECTOR_DISTANCE = 100  # Distance between subsectors (km)

    #     def generate_circular_waypoints(start, num_waypoints, radius):
    #         waypoints = []
    #         for i in range(num_waypoints):
    #             angle = 360.0 * i / num_waypoints
    #             dlat = radius * np.cos(np.radians(angle)) / 111  # Approximation: 1 degree latitude ≈ 111 km
    #             dlon = radius * np.sin(np.radians(angle)) / (111 * np.cos(np.radians(start[0])))
    #             waypoints.append((start[0] + dlat, start[1] + dlon))
    #         return waypoints

    #     def generate_subsector_points(start, end, subsector_count, subsector_distance):
    #         subsector_points = []
    #         great_circle_bearing = np.arctan2(end[1] - start[1], end[0] - start[0])

    #         for i in range(-subsector_count, subsector_count + 1):
    #             bearing_offset = i * (subsector_distance / haversine(start[0],start[1], end[0], end[1]))
    #             new_bearing = great_circle_bearing + bearing_offset
    #             dx = subsector_distance * np.cos(new_bearing) / 111
    #             dy = subsector_distance * np.sin(new_bearing) / (111 * np.cos(np.radians(start[0])))
    #             new_point = (start[0] + dx, start[1] + dy)
    #             subsector_points.append(new_point)
    #         return subsector_points

    #     def generate_isochrones_for_subsectors(start, end, speed, num_isochrones=3, step_size=STEP_SIZE):
    #         subsector_points = generate_subsector_points(start, end, SUBSECTOR_COUNT, SUBSECTOR_DISTANCE)
    #         subsector_paths = {i: [start] for i in range(-SUBSECTOR_COUNT, SUBSECTOR_COUNT + 1)}
    #         total_distances = {i: 0.0 for i in range(-SUBSECTOR_COUNT, SUBSECTOR_COUNT + 1)}

    #         for i, point in enumerate(subsector_points):
    #             subsector_key = i - SUBSECTOR_COUNT  # Adjust index to match subsector_paths keys
    #             initial_distance = haversine(start[0],start[1], point[0], point[1])
    #             subsector_paths[subsector_key].append(point)
    #             total_distances[subsector_key] += initial_distance

    #         for n in range(1, num_isochrones + 1):
    #             max_distance = n * speed * DELTA_T

    #             for subsector_idx, subsector_waypoints in subsector_paths.items():
    #                 last_waypoint = subsector_waypoints[-1]
    #                 new_waypoints = generate_circular_waypoints(last_waypoint, NUM_WAYPOINTS, step_size)
                    
    #                 valid_waypoints = []
    #                 for wp in new_waypoints:
    #                     dis, wp= get_nearest_kdtree_node(self.kdtree, wp[0], wp[1])
    #                     wp = (self.all_points[wp[0][0]])
    #                     wp = (wp[0], wp[1])
    #                     if wp in self.coord_to_bathy and self.coord_to_bathy[wp] < 0:  # Check bathymetry depth
    #                         dist_to_end = haversine(wp[0],wp[1], end[0], end[1])
    #                         valid_waypoints.append((wp, dist_to_end))

    #                 valid_waypoints.sort(key=lambda x: x[1])

    #                 if valid_waypoints:
    #                     best_waypoint, dist_to_end = valid_waypoints[0]
    #                     subsector_paths[subsector_idx].append(best_waypoint)
    #                     total_distances[subsector_idx] += haversine(last_waypoint[0],last_waypoint[1], best_waypoint[0], best_waypoint[1])

    #                 if haversine(subsector_paths[subsector_idx][-1][0],subsector_paths[subsector_idx][-1][1], end[0], end[1]) < speed * DELTA_T:
    #                     break


    #         return subsector_paths, total_distances
    #     p,d = generate_isochrones_for_subsectors(start=start, end=end,speed=10,num_isochrones=45)

    #     res_path = self.isochroneastar(p, d, end)
    #     l = 0
    #     for i in p:
    #         print(p[i][-1], res_path[0])
    #         if p[i][-1] == res_path[0]:
    #             t = p[i][::-1]
    #             res_path.extend(t)
                
    #     return res_path
    
    # def isochroneastar(self, subsectors, distances, end):
    #     end_points_to_cell = {}
        
    #     for i in subsectors:
    #         end_points_to_cell[subsectors[i][-1]], _ = self.get_nearest_cell(subsectors[i][-1][0], subsectors[i][-1][1])
    #         print(end_points_to_cell[subsectors[i][-1]].lat, end_points_to_cell[subsectors[i][-1]].lon)

    #     subsector_row_col = []
    #     for i in end_points_to_cell:
    #         cell = end_points_to_cell[i]
            
    #         row, col = self.point_to_ind[(cell.lat, cell.lon)]
    #         subsector_row_col.append((row, col))
        
    #     end_cell, _ = self.get_nearest_cell(end[0], end[1])

    #     end_row , end_col = self.point_to_ind[(end_cell.lat, end_cell.lon)]
    

    #     num_rows = len(self.grid)

    #     priority_queue = []

    #     distances = np.full((num_rows, max(self.num_cols_per_row)), np.inf)
    #     for i in range(0, len(subsector_row_col)):
    #         distances[subsector_row_col[i][0], subsector_row_col[i][1]] = 0
    #         heapq.heappush(priority_queue, (0, (subsector_row_col[i][0], subsector_row_col[i][1])))

    #     prev = np.full((num_rows, max(self.num_cols_per_row)), None)

    #     # Priority queue (min-heap) with (priority, (row, col))
        
    #     while priority_queue:
    #         current_priority, (row, col) = heapq.heappop(priority_queue)
    #         # Check if we reached the goal
    #         if(row == end_row and col == end_col):
    #             break

    #         # Consider all 8 possible directions
    #         directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
    #         for dr, dc in directions:
    #             r, c = row + dr, col + dc
    #             if 0 <= r < num_rows and 0 <= c < self.num_cols_per_row[r]:
    #                 neighbor = self.grid[r][c]
    #                 if neighbor is not None and not neighbor.is_land and neighbor.bathymetry_depth <= -20:
    #                     # Calculate actual distance between current cell and neighbor
    #                     distance = haversine(
    #                         self.grid[row][col].lat, self.grid[row][col].lon,
    #                         neighbor.lat, neighbor.lon
    #                     )

    #                     new_distance = distances[row][col] + distance
    #                     heuristic = haversine(neighbor.lat, neighbor.lon, self.grid[end_row][end_col].lat, self.grid[end_row][end_col].lon)
    #                     priority = new_distance + heuristic

    #                     if new_distance < distances[r][c]:
    #                         distances[r][c] = new_distance
    #                         prev[r][c] = (row, col)
    #                         heapq.heappush(priority_queue, (priority, (r, c)))

    #     # Reconstruct the shortest path
    #     path = []
    #     step = (end_row, end_col)
    #     while step is not None:
    #         path.append(step)
    #         step = prev[step[0]][step[1]]
    #     path.reverse()

    #     # Convert indices to lat/lon for path
    #     path_lat_lon = [(self.grid[row][col].lat, self.grid[row][col].lon) for row, col in path]

    #     print("Size of Path:", len(path))
    #     print("Total Distance Taken:", distances[end_row][end_col])
    #     return path_lat_lon

    
    # def dynamic_astarr(self, start_lat, start_lon, end_lat, end_lon, kdtree, bathymetry, all_points):
    #     # Priority Queue (min-heap)
    #     open_list = []
    #     count = 0
    #     # Start node: (current_cost, heuristic_cost, (lat, lon), heading, parent)
    #     start_node = (0, haversine(start_lat, start_lon, end_lat, end_lon), (start_lat, start_lon), None, None)
    #     heapq.heappush(open_list, start_node)

    #     # Closed set to store visited nodes
    #     visited = set()
        
    #     # Successor logic constants
    #     STEP_SIZE = 10  # Step distance in km
    #     HEADING_ADJUSTMENT = 10  # Degrees change for successors

    #     # Heuristic: Haversine distance to destination
    #     def heuristic(lat, lon, end_lat, end_lon):
    #         return haversine(lat, lon, end_lat, end_lon)

    #     # Generate successors based on heading adjustment
    #     def generate_successors(lat, lon, heading):
    #         successors = []
    #         for j in range(1, 36):  # Dynamic search with range of headings
    #             adjusted_heading = (heading + j * HEADING_ADJUSTMENT) % 360
    #             dlat = STEP_SIZE * np.cos(np.radians(adjusted_heading)) / 111
    #             dlon = STEP_SIZE * np.sin(np.radians(adjusted_heading)) / (111 * np.cos(np.radians(lat)))
    #             new_point = (lat + dlat, lon + dlon)
    #             successors.append((new_point, adjusted_heading))
    #         return successors

    #     # Dynamic A* loop
    #     while open_list:
    #         # Get the node with the lowest f = g + h
    #         current_cost, current_heuristic, (lat, lon), heading, parent = heapq.heappop(open_list)
    #         # print(count, end=' ')
    #         count += 1
    #         # Check if we've reached the destination
    #         if heuristic(lat, lon, end_lat, end_lon) < 5:  # Close enough to destination
    #             print(f"Destination reached: ({lat}, {lon})")
    #             return (lat, lon), current_cost  # Return path and total cost
            
    #         # Mark this node as visited
    #         visited.add((lat, lon))
            
    #         # If a heading is not provided (first node), calculate initial heading
    #         if heading is None:
    #             heading = np.arctan2(end_lon - lon, end_lat - lat)
            
    #         # Generate successors based on the current heading
    #         successors = generate_successors(lat, lon, heading)
    #         for (succ_lat, succ_lon), new_heading in successors:
    #             # Avoid already visited nodes
    #             if (succ_lat, succ_lon) in visited:
    #                 continue
                
    #             # Find the closest bathymetry point and validate the successor
    #             dis, closest_node = get_nearest_kdtree_node(kdtree, succ_lat, succ_lon)
    #             closest_node = all_points[closest_node[0][0]]
    #             closest_node = (closest_node[0], closest_node[1])
    #             if bathymetry[closest_node] >= -10:  # Check if it's not land
    #                 continue
                
    #             # Calculate the cost from the current node to the successor
    #             travel_cost = haversine(lat, lon, succ_lat, succ_lon)
    #             total_cost = current_cost + travel_cost
                
    #             # Calculate heuristic (Haversine distance to the destination)
    #             succ_heuristic = heuristic(succ_lat, succ_lon, end_lat, end_lon)
                
    #             # Push the successor into the priority queue
    #             heapq.heappush(open_list, (total_cost, succ_heuristic, (succ_lat, succ_lon), new_heading, (lat, lon)))
        
    #     print("No valid route found.")
    #     return None, float('inf')            
        
    # def dynamic_astar(self,start_lat, start_lon, end_lat, end_lon):
    #     final_point, total_distance = self.dynamic_astarr(start_lat=start_lat, start_lon=start_lon, end_lat=end_lat, end_lon=end_lon, kdtree=self.kdtree, bathymetry=self.coord_to_bathy, all_points=self.all_points)
    #     return final_point, total_distance
    
    # def updatedastar(self,start_lat, start_lon, end_lat, end_lon):
    #     start_cell, _ = self.get_nearest_cell(start_lat, start_lon)
    #     end_cell, _ = self.get_nearest_cell(end_lat, end_lon)
    #     res = 1

    #     if self.coord_to_bathy[(start_cell.lat, start_cell.lon)] > -5 or self.coord_to_bathy[(end_cell.lat, end_cell.lon)] > -5:
    #         print("Points cannot be on land")
    #         return []
        
    #     start_row = start_cell.lat
    #     start_col = start_cell.lon

    #     end_row = end_cell.lat
    #     end_col = end_cell.lon


    #     distances = {}
    #     distances[(start_row,start_col)] = 0
    #     prev = {}
    #     vis = set()
    #     near = start_cell

    #     # Priority queue (min-heap) with (priority, (row, col))
    #     priority_queue = []
    #     heapq.heappush(priority_queue, (0, (start_row, start_col, start_cell)))
    #     traversed = []
    #     cnt = 0
    #     while priority_queue:
    #         current_priority, (row, col, near) = heapq.heappop(priority_queue)
    #         traversed.append((row,col))
            
    #         vis.add(near)

    #         # Check if we reached the goal
    # #         print(f"{row,col}",end = " ")
    #         if cnt > 20000:
    #             end_row = row
    #             end_col = col
    #             break
    #         cnt += 1
    #         print("Iteration :", cnt)

    #         if(abs(row - end_row) <= res and abs(col - end_col) <= res):
    #             end_row = row
    #             end_col = col
    #             break
                
    #         flag = False
    #         # Consider all 8 possible directions
    #         directions = np.radians(np.arange(0,360,10))
    #         # print(directions[-1])
    #         # directions = [0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,
    #         #               200,210,220,230,240,250,260,270,280,290,300,310,320,330,340,350,360]
    # #         directions = [0,20,40,80,100,120,140,160,180,200,220,240,260,280,300,320,340,360]
    #         for theta in directions:
    #             r = row + res*np.cos(theta)
    #             c = col + res * np.sin(theta) / np.cos(np.radians(row))

    #             #checking if valid neighbour or not
    #             nearest_cell, _ = self.get_nearest_cell(r,c)
                
    #             if nearest_cell.bathymetry_depth > 0 or nearest_cell in vis or nearest_cell.near_coastline:
    #                 continue

    #             distance = haversine(row,col,r,c)
    #             new_distance = distances[(row,col)] + distance
    #             heuristic = haversine(r, c, end_row, end_col)
    #             priority = heuristic + new_distance

    #             if (r,c) not in distances or new_distance < distances[(r,c)]:
    #                 distances[(r,c)] = new_distance
    #                 prev[(r,c)] = (row, col)
    #                 heapq.heappush(priority_queue, (priority, (r, c, nearest_cell)))


    #     # Reconstruct the shortest path
    #     path = []
    #     step = (end_row, end_col)
    #     path.append(step)
    #     while step is not None:
    #         if((step[0],step[1]) in prev):
    #             step = prev[(step[0],step[1])]
    #             path.append(step)
    #         else:
    #             break
    #     path.reverse()
    # #     print('path',path)
    #     # print('total distance : ',distances[(end_row,end_col)])
    #     return (path,traversed)
        