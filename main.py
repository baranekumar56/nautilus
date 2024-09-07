from gridGeneration.gridGen import *
import matplotlib.pyplot as plt
import geopandas as gpd
from shapely.geometry import Point, LineString
import cartopy.crs as ccrs
import cartopy.feature as cfeature



def plot_path_on_map(path_lat_lon, traversed):
    # Print path_lat_lon to debug
    print(f"Path coordinates: {path_lat_lon}")

    # Load Indian subcontinent shapefile or GeoJSON
    india_map = gpd.read_file('projectmaterials/natural-earth-vector-master/10m_physical/ne_10m_land.shp')

    # Check if path_lat_lon is empty
    if not path_lat_lon:
        raise ValueError("Path coordinates are empty")

    # Extract latitude and longitude separately for path and traversed points
    lats_path = [lat for lat, lon in path_lat_lon]
    lons_path = [lon for lat, lon in path_lat_lon]
 
    lats_traversed = [lat for lat, lon in traversed]
    lons_traversed = [lon for lat, lon in traversed]

    # Define fixed colors for path and traversed points
    color_traversed = 'orange'
    color_path = 'red'

    # Plot the map and the points
    fig, ax = plt.subplots(figsize=(12, 8))
    india_map.plot(ax=ax, color='lightgrey')

    # Plot traversed points with the same color and no borders
    # ax.scatter(lons_traversed, lats_traversed, c=color_traversed, s=5, label='Traversed Points', edgecolors='none')

    # Plot the path points with the same color and no borders
    ax.scatter(lons_path, lats_path, c=color_path, s=5, label='Path Points', edgecolors='none')

    # Zoom in on the Indian subcontinent region
    ax.set_xlim([30, 130])  # Longitude range for the Indian subcontinent
    ax.set_ylim([-35, 35])    # Latitude range for the Indian subcontinent

    plt.title('Path Traversal on the Indian Subcontinent')
    plt.xlabel('Longitude')
    plt.ylabel('Latitude')
    plt.legend()
    plt.show()


# Example usage with your Grid class
grid = Grid()
start_lat, start_lon = 13.0827, 80.2707
  # Replace with your start coordinates
end_lat, end_lon =-7.740423, 105.260764 # Replace with your end coordinates

(path_lat_lon1,traversed1) = grid.a_star(start_lat, start_lon, end_lat, end_lon)
# with open('path.csv' , 'w') as f:
#     for i in path_lat_lon:
#         s = str(i[0]) + "," + str(i[1]) +"\n"
#         f.write(s)
plot_path_on_map(path_lat_lon1,traversed1)
print(path_lat_lon1.__len__())

# with open('path.csv' , 'r') as f:
#     for i in path_lat_lon:
#         s = str(i[0]) + "," + str(i[1]) +"\n"
#         f.write(s)
