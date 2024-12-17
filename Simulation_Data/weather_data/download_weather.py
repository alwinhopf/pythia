import geopandas as gpd
import pandas as pd
import requests
from datetime import datetime, timedelta
import os
import numpy as np

def fetch_weather_data(lat, lon):
    base_url = "https://archive-api.open-meteo.com/v1/archive"
    end_date = datetime.now().strftime("%Y-%m-%d")
    start_date = (datetime.now() - timedelta(days=365)).strftime("%Y-%m-%d")
    
    params = {
        "latitude": lat,
        "longitude": lon,
        "start_date": start_date,
        "end_date": end_date,
        "daily": "temperature_2m_max,temperature_2m_min,precipitation_sum,shortwave_radiation_sum",
        "timezone": "America/New_York"
    }
    
    response = requests.get(base_url, params=params)
    return response.json()

def create_wth_file(data, lat, lon, output_dir):
    df = pd.DataFrame(data['daily'])
    df['date'] = pd.to_datetime(df['time'])
    
    filename = f"US{lat:.2f}N{abs(lon):.2f}W.WTH"
    filepath = os.path.join(output_dir, filename)
    
    with open(filepath, 'w') as f:
        f.write(f"*WEATHER DATA : {lat:.2f}N, {abs(lon):.2f}W\n")
        f.write(f"@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT\n")
        f.write(f"  USXX   {lat:.3f}  {lon:.3f}     0  00.0  00.0  0.00  0.00\n")
        f.write("@DATE  SRAD  TMAX  TMIN  RAIN\n")
        
        for _, row in df.iterrows():
            date_str = row['date'].strftime("%y%j")
            srad = row['shortwave_radiation_sum'] / 1000000  # Convert J/m^2 to MJ/m^2
            tmax = row['temperature_2m_max']
            tmin = row['temperature_2m_min']
            rain = row['precipitation_sum']
            f.write(f"{date_str} {srad:5.1f} {tmax:5.1f} {tmin:5.1f} {rain:5.1f}\n")
    
    print(f"Created {filename}")

def generate_grid(gdf, resolution=0.5):
    xmin, ymin, xmax, ymax = gdf.total_bounds
    x_coords = np.arange(np.floor(xmin), np.ceil(xmax), resolution)
    y_coords = np.arange(np.floor(ymin), np.ceil(ymax), resolution)
    grid_points = []
    
    for x in x_coords:
        for y in y_coords:
            point = gpd.points_from_xy([x + resolution/2], [y + resolution/2])[0]
            if gdf.contains(point).any():
                grid_points.append(point)
    
    return gpd.GeoDataFrame(geometry=grid_points, crs=gdf.crs)

def generate_wth_files(shapefile_path, output_dir):
    gdf = gpd.read_file(shapefile_path)
    gdf = gdf.to_crs(epsg=4326)  # Ensure the CRS is in lat/lon
    
    grid = generate_grid(gdf)
    
    os.makedirs(output_dir, exist_ok=True)
    
    for idx, point in grid.iterrows():
        lat, lon = point.geometry.y, point.geometry.x
        weather_data = fetch_weather_data(lat, lon)
        create_wth_file(weather_data, lat, lon, output_dir)

# Usage
shapefile_path = "C:/pythia/Simulation_Data/USA/shapes/cb_2018_us_county_500k.shp"
output_dir = "C:/pythia/Simulation_Data/USA/Weather"
generate_wth_files(shapefile_path, output_dir)
