import os
import geopandas as gpd

input_dir = "C:/Users/alwin/Documents/GitHub/pythia/Input_Data_Preparation"

# Read the gridfile and contiguous US shapefile
grid_path = os.path.join(input_dir, "5arc_land_nasa_v3.shp")
grid = gpd.read_file(grid_path)
shapefile_path = os.path.join(input_dir, "contiguous_us2.shp")
shapefile = gpd.read_file(shapefile_path)

# Ensure both datasets are in the same coordinate reference system
grid = grid.to_crs(shapefile.crs)

# Perform spatial join to keep only points within contiguous US
filtered_grid = gpd.sjoin(grid, shapefile, predicate='within')

# Create output path in the same directory
output_path = os.path.join(input_dir, "filtered_grid_contiguous_us2.shp")

# Save the filtered grid to a new shapefile
filtered_grid.to_file(output_path)
