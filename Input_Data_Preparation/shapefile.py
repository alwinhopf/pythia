import os
import geopandas as gpd

input_dir = "C:/Users/alwin/Documents/GitHub/pythia/Input_Data_Preparation"

# Read the shapefile
#https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html
shapefile_path = os.path.join(input_dir, "cb_2018_us_state_500k.shp")
us_states = gpd.read_file(shapefile_path)

# Print the unique values to see what we're working with
print("Available states:", us_states['NAME'].unique())

# Filter for continental US (excluding Alaska=02, Hawaii=15, and territories)
contiguous_states = us_states[~us_states['STUSPS'].isin(['AK', 'HI', 'PR', 'VI', 'AS', 'GU', 'MP'])]

# Create output path in the same directory
output_path = os.path.join(input_dir, "contiguous_us.shp")

# Save to the specified path
contiguous_states.to_file(output_path)