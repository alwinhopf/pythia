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


Forecast22<-read.csv("C:/pythia/Simulation_Data/OUTPUT/Sri_Lanka/Rice/Sri_Lanka_Rice.csv") #example csv file
plot_yld_data <- st_as_sf( Forecast22, coords = c("LONGITUDE", "LATITUDE"), crs =4326)
st_crs(plot_yld_data)
AEZ<-st_read("C:/pythia/Simulation_Data/Sri_Lanka/shapes/SL.shp")



plot_TOT_PROD=ggplot()+
  geom_sf(data= plot_yld_data, aes(color=HARVEST_AREA*HWAM/1000),shape=15, size = 8.12)+ #calculate HWAH standard deviation first and put it in separate column HWAHSD
  labs( color="Tot Prod(ton)")+
  theme(legend.key.size = unit(5.0, "cm"),
        legend.key.width = unit(2.5,"cm")) +
  geom_sf(data=AEZ, size=10.05, alpha=10.05, fill=NA)+
  labs(x="LONGITUDE", y="LATITUDE")+
  theme(text=element_text(size=22,  family="Arial"))+
  theme_bw(base_size = 22) +
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
path_output <- "D:/ACASA_project/Data_Analysis/OUTPUT"
ggsave(plot = plot_TOT_PROD, filename = "C:/pythia/Simulation_Data/OUTPUT/Sri_Lanka_Rice_Total_Prod.jpeg", dpi=300,
       height = 11,width = 10)




plot_yield=ggplot()+
  geom_sf(data= plot_yld_data, aes(color=HWAM),shape=15, size = 8.12)+ #calculate HWAH standard deviation first and put it in separate column HWAHSD
  labs( color="Yield(kg/ha)")+
  theme(legend.key.size = unit(5.0, "cm"),
        legend.key.width = unit(2.5,"cm")) +
  geom_sf(data=AEZ, size=15.05, alpha=15.05, fill=NA)+
  labs(x="LONGITUDE", y="LATITUDE")+
  theme(text=element_text(size=22,  family="Arial"))+
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
path_output <- "D:/ACASA_project/Data_Analysis/OUTPUT"
ggsave(plot = plot_yield, filename = "C:/pythia/Simulation_Data/OUTPUT/Sri_Lanka_Rice_yield.jpeg", dpi=300,
       height = 11,width = 10)


