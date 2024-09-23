# example file to run the algorithm and display map using geopandas



from gridGeneration.gridGen import *
import matplotlib.pyplot as plt
import geopandas as gpd
from shapely.geometry import Point, LineString
import cartopy.crs as ccrs
import cartopy.feature as cfeature



def plot_path_on_map(ax,path_lat_lon, color):
    if not path_lat_lon:
        raise ValueError("Path coordinates are empty")

    lats_path = [lat for lat, lon in path_lat_lon]
    lons_path = [lon for lat, lon in path_lat_lon]

    color_path = color

    

    ax.scatter(lons_path, lats_path, c=color_path, s=5, label='Path Points', edgecolors='none')

    
grid = Grid()
start_lat, start_lon = 13.0827, 81.2707
end_lat, end_lon =13.740423, 84.260764
t = time.time()
path_lat_lon1 = grid.a_star(start_lat, start_lon, end_lat, end_lon,0,10,True)
path_lat_lon2 = grid.a_star(start_lat, start_lon, end_lat, end_lon,0,10,False)
print('time taken', time.time() - t)
india_map = gpd.read_file('projectmaterials/natural-earth-vector-master/10m_physical/ne_10m_land.shp')
fig, ax = plt.subplots(figsize=(12, 8))
india_map.plot(ax=ax, color='lightgrey')
ax.set_xlim([30, 130])  # Longitude range for the Indian subcontinent
ax.set_ylim([-35, 35])    # Latitude range for the Indian subcontinent

plot_path_on_map(ax, path_lat_lon1,'red')
plot_path_on_map(ax,path_lat_lon2,'orange')
print(path_lat_lon1.__len__())

plt.title('Path Traversal on the Indian Subcontinent')
plt.xlabel('Longitude')
plt.ylabel('Latitude')
plt.legend()
plt.show()
# with open('path.csv' , 'r') as f:
#     for i in path_lat_lon:
#         s = str(i[0]) + "," + str(i[1]) +"\n"
#         f.write(s)
