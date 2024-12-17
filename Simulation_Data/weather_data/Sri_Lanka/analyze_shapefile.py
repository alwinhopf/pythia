import geopandas as gpd

# Load the shapefile
shapefile_path = "C:/pythia/Simulation_Data/USA/shapes/Sri_Lanka.shp"
data = gpd.read_file(shapefile_path)

# Display basic information
print(data.head())  # Show the first few rows of attribute data
print(data.crs)     # Show the coordinate reference system
print(data.columns) # List all attribute columns
