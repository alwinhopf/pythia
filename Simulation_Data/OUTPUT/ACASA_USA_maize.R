##Maps
library(ggplot2)
library(sf)
library(sp)
library(raster)
library(ggspatial)
library(rnaturalearth)
library(rnaturalearthdata)
library(tidyverse)
library(readxl)
library(data.table)
library(readr)
library(sf)
library(terra)
library(raster)

library(dplyr)

####### NEW CODE

#read csv file from pythia
raw_pythia_output <- read.csv("C:/pythia/Simulation_Data/OUTPUT/USA/Maize/USA_maize_rf_highN/USA_maize_rf_highN.csv")
                               
#get mean for yield
mean_yield_df <- raw_pythia_output %>% group_by(LATITUDE, LONGITUDE) %>%
  summarise(mean_yield = mean(HWAH, na.rm = T))

#transform the dataframe into a shapefile
coordinates(mean_yield_df) <- ~LONGITUDE+LATITUDE
proj4string(mean_yield_df) <- CRS("+proj=longlat +datum=WGS84")

AEZ<-st_read("C:/pythia/Simulation_Data/USA/shapes/cb_2022_us_nation_20m.shp")


#PLOT ONLY MEAN YIELD VALUES 
plot_TOT_PROD=ggplot()+
  geom_sf(data= sf::st_as_sf(mean_yield_df), aes(color=mean_yield),shape=15, size = 8.12)+ #calculate HWAH standard deviation first and put it in separate column HWAHSD
  #geom_map(data=mean_yield_df, map = mean_yield_df, aes(long=LONGITUDE, lat=LATITUDE))+
  labs( color="Yield(kg/ha)")+
  theme(legend.key.size = unit(5.0, "cm"),
        legend.key.width = unit(2.5,"cm")) +
  geom_sf(data=AEZ, size=15.05, alpha=15.05, fill=NA)+
  labs(x="LONGITUDE", y="LATITUDE")+
  theme(text=element_text(size=26,  family="Arial"))+
  theme_bw(base_size = 26) +
  theme(text=element_text(family="Arial"))+
  theme(axis.title.x = element_text(colour = "black"))+
  theme(axis.title.y = element_text(colour = "black"))+
  theme(axis.text.x = element_text(colour = "black"))+
  theme(axis.text.y = element_text(colour = "black"))+
  theme(panel.grid.major = element_blank())+
  theme(panel.grid.minor = element_blank())+
  scale_color_gradientn(colours = rainbow(7),
                        n.breaks=5) +
  annotation_scale(location = "br", width_hint = 0.4) +
  annotation_north_arrow(location = "tl", which_north = "true", 
                         pad_x = unit(0.2, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) 


path_output <- "C:/pythia/Simulation_Data/OUTPUT"
ggsave(plot = plot_TOT_PROD, filename = "C:/pythia/Simulation_Data/OUTPUT/USA_maize_rf_highN_Yield.jpeg", dpi=300,
       height = 11,width = 10)
plot_TOT_PROD
