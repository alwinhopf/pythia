library(sf)
library(dplyr)
library(httr)
library(jsonlite)
library(lubridate)

# Function to fetch weather data from Open-Meteo API
fetch_weather_data <- function(lat, lon) {
  base_url <- "https://archive-api.open-meteo.com/v1/archive"
  end_date <- format(Sys.Date(), "%Y-%m-%d")
  start_date <- format(Sys.Date() - 365, "%Y-%m-%d")
  
  params <- list(
    latitude = lat,
    longitude = lon,
    start_date = start_date,
    end_date = end_date,
    daily = "temperature_2m_max,temperature_2m_min,precipitation_sum,shortwave_radiation_sum",
    timezone = "America/New_York"
  )
  
  response <- GET(url = base_url, query = params)
  return(fromJSON(content(response, "text", encoding = "UTF-8")))
}

# Function to download the US shapefile
download_us_shapefile <- function(output_dir) {
  url <- "https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_nation_20m.zip"
  zip_file <- file.path(output_dir, "us_shapefile.zip")
  
  # Download the zip file
  GET(url, write_disk(zip_file, overwrite = TRUE))
  
  # Unzip the file
  unzip(zip_file, exdir = output_dir)
  
  # Return the path to the shapefile
  return(file.path(output_dir, "cb_2022_us_nation_20m.shp"))
}

# Function to generate a grid at 0.5° x 0.5° resolution
generate_grid <- function(gdf, resolution = 0.5) {
  bbox <- st_bbox(gdf)
  x_coords <- seq(floor(bbox["xmin"]), ceiling(bbox["xmax"]), by = resolution)
  y_coords <- seq(floor(bbox["ymin"]), ceiling(bbox["ymax"]), by = resolution)
  
  grid_points <- expand.grid(x = x_coords + resolution / 2, y = y_coords + resolution / 2)
  grid_sf <- st_as_sf(grid_points, coords = c("x", "y"), crs = st_crs(gdf))
  
  grid_sf <- grid_sf[st_intersects(grid_sf, gdf, sparse = FALSE), ]
  return(grid_sf)
}

# Function to create .WTH files in DSSAT format
create_wth_file <- function(data, lat, lon, output_dir) {
  df <- as.data.frame(data$daily)
  df$date <- as.Date(df$time)
  
  filename <- sprintf("US%.2fN%.2fW.WTH", lat, abs(lon))
  filepath <- file.path(output_dir, filename)
  
  con <- file(filepath, "w")
  writeLines(sprintf("*WEATHER DATA : %.2fN, %.2fW", lat, abs(lon)), con)
  writeLines("@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT", con)
  writeLines(sprintf("  USXX   %.3f  %.3f     0  00.0  00.0  0.00  0.00", lat, lon), con)
  writeLines("@DATE  SRAD  TMAX  TMIN  RAIN", con)
  
  for (i in seq_len(nrow(df))) {
    date_str <- format(df$date[i], "%y%j")
    srad <- df$shortwave_radiation_sum[i] / 1000000 # Convert J/m^2 to MJ/m^2
    tmax <- df$temperature_2m_max[i]
    tmin <- df$temperature_2m_min[i]
    rain <- df$precipitation_sum[i]
    writeLines(sprintf("%s %5.1f %5.1f %5.1f %5.1f", date_str, srad, tmax, tmin, rain), con)
  }
  
  close(con)
  cat("Created", filename, "\n")
}

# Main function to generate .WTH files
generate_wth_files <- function(output_dir) {
  shapefile_path <- download_us_shapefile(output_dir) # Download the shapefile
  
  gdf <- st_read(shapefile_path) # Read the shapefile
  gdf <- st_transform(gdf, crs = st_crs(4326)) # Ensure CRS is in lat/lon
  
  grid <- generate_grid(gdf) # Generate a grid
  
  dir.create(file.path(output_dir, "Weather"), showWarnings = FALSE, recursive = TRUE) # Create output directory
  
  centroids <- st_centroid(grid) # Calculate centroids of grid cells
  coords <- st_coordinates(centroids) # Extract coordinates
  
  for (i in seq_len(nrow(coords))) {
    lat <- coords[i, "Y"]
    lon <- coords[i, "X"]
    weather_data <- fetch_weather_data(lat, lon) # Fetch weather data for each point
    create_wth_file(weather_data, lat, lon, file.path(output_dir)) # Create .WTH file
  }
}

# Usage example
output_dir <- "C:/pythia/Simulation_Data/weather_data/USA"
generate_wth_files(output_dir)
