from gridGeneration.gridGen import *
import matplotlib.pyplot as plt
import geopandas as gpd
from shapely.geometry import Point, LineString
import cartopy.crs as ccrs
import cartopy.feature as cfeature



def plot_path_on_map( subsector_paths, traversed):
    print(f"Main Path coordinates: {path_lat_lon}")

    india_map = gpd.read_file('projectmaterials/natural-earth-vector-master/10m_physical/ne_10m_land.shp')

    if not path_lat_lon:
        raise ValueError("Main path coordinates are empty")


    color_traversed = 'orange'
    color_path = 'red'
    
    subsector_colors = plt.cm.viridis(np.linspace(0, 1, len(subsector_paths)))

    fig, ax = plt.subplots(figsize=(12, 8))
    india_map.plot(ax=ax, color='lightgrey')

    # for i, subsector in enumerate(subsector_paths.values()):
    #     lats_subsector = [lat for lat, lon in subsector]
    #     lons_subsector = [lon for lat, lon in subsector]
    #     ax.plot(lons_subsector, lats_subsector, color=subsector_colors[i], label=f'Subsector {i+1}')

    # lats_subsector = [lat for lat, lon in traversed]
    # lons_subsector = [lon for lat, lon in traversed]
    # ax.scatter(lons_subsector, lats_subsector, color="yellow",s=1, label=f'Iso Chrone A*')

    lats_subsector = [lat for lat, lon in subsector_paths]
    lons_subsector = [lon for lat, lon in subsector_paths]
    ax.plot(lons_subsector, lats_subsector, color="red", label=f'Iso Chrone A*')



    ax.set_xlim([30, 130])  
    ax.set_ylim([-35, 30])  
    plt.title('Path and Subsectors Traversal on the Indian Subcontinent')
    plt.xlabel('Longitude')
    plt.ylabel('Latitude')
    plt.legend()
    plt.show()


grid = Grid()
start_lat, start_lon = 11.3948, 115.33232
end_lat, end_lon =13.692259, 80.548244
t = time.time()
path_lat_lon, distances = grid.a_star(start_lat, start_lon, end_lat, end_lon)
x = time.time()
print("Time Took: ", x - t)
# with open('path.csv' , 'w') as f:
#     for i in path_lat_lon:
#         s = str(i[0]) + "," + str(i[1]) +"\n"
#         f.write(s)

# print("Path by each subsector:")
# for i in distances:
#     print("Subsector ", i, ":", distances[i])
print(haversine(start_lat, start_lon, end_lat, end_lon))
plot_path_on_map(path_lat_lon, distances)
print(path_lat_lon.__len__())

# with open('path.csv' , 'r') as f:
#     for i in path_lat_lon:
#         s = str(i[0]) + "," + str(i[1]) +"\n"
#         f.write(s)
