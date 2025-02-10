import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
from shapely.geometry import Point
from tqdm import tqdm
import os

# Define input directory
input_dir = "C:/pythia/Input_Data_Preparation/"

print("Step 1: Reading the shapefile...")
shapefile_path = os.path.join(input_dir, "contiguous_us.shp")
shapefile = gpd.read_file(shapefile_path)
print("Shapefile loaded successfully.")
print(f"Shapefile CRS: {shapefile.crs}")
print(f"Shapefile bounds: {shapefile.total_bounds}")
print(f"Number of features in shapefile: {len(shapefile)}")

print("\nStep 2: Getting the bounding box of the shapefile...")
minx, miny, maxx, maxy = shapefile.total_bounds
print(f"Bounding box: ({minx}, {miny}, {maxx}, {maxy})")

print("\nStep 3: Creating a 0.5 * 0.5 degree grid of points...")
x_coords = np.arange(np.floor(minx), np.ceil(maxx), 5.00)
y_coords = np.arange(np.floor(miny), np.ceil(maxy), 5.00)

total_points = len(x_coords) * len(y_coords)
points = []
latitudes = []
longitudes = []

with tqdm(total=total_points, desc="Creating grid points") as pbar:
    for x in x_coords:
        for y in y_coords:
            points.append(Point(x, y))
            longitudes.append(x)
            latitudes.append(y)
            pbar.update(1)

print("\nStep 4: Creating a GeoDataFrame from the points...")
grid = gpd.GeoDataFrame(geometry=points, crs=shapefile.crs)
grid['ID'] = range(1, len(grid) + 1)
#grid['ID'] = [f"{i:08d}" for i in range(1, len(grid) + 1)]
grid['Latitude'] = latitudes
grid['Longitude'] = longitudes
grid['nasapid'] = np.arange(1, len(grid) + 1, dtype=np.int64)
grid['LatNP'] = np.round(grid['Latitude'], 2)
grid['LonNP'] = np.round(grid['Longitude'], 2)

print("GeoDataFrame created successfully.")
print(f"Created {len(points)} grid points.")
print(f"Grid CRS: {grid.crs}")
print(f"Grid bounds: {grid.total_bounds}")
print(f"Number of grid points: {len(grid)}")

print("\nStep 5: Clipping the points to the shapefile boundary...")
points_within = grid[grid.intersects(shapefile.unary_union)]
print(f"Number of points within or on the boundary: {len(points_within)}")

print("Step 6: Saving grid points to USA_gridpoints.shp...")
output_shapefile = os.path.join(input_dir, "USA_contiguous_states_gridpoints_5.00degree.shp")
points_within.to_file(output_shapefile, driver="ESRI Shapefile")
print(f"Grid points saved successfully to {output_shapefile}")

print("\nStep 7: Creating and saving the plot...")
fig, ax = plt.subplots(figsize=(12, 8))
shapefile.plot(ax=ax, edgecolor='black', facecolor='none')
points_within.plot(ax=ax, color='red', markersize=5)

# Set title and labels
plt.title("5.00 * 5.00 Degree Grid Points Over Shapefile")
plt.xlabel("Longitude")
plt.ylabel("Latitude")

# Save the plot as a JPEG file
output_figure = os.path.join(input_dir, "USA_contiguous_states_gridpoints_5.00degree.jpg")
plt.savefig(output_figure, dpi=600, bbox_inches='tight')
print(f"Plot saved as '{output_figure}'")

# Close the plot to free up memory
plt.close(fig)
