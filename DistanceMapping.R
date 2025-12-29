#####Measuring Distance From Set#####

#Author: Katie Flowers
#Date last modified: 28 December 2025

#####-----------------------------------------------#####

#set your working directory however you choose
#from dropdown menu: Session > Set Working Directory > Choose Directory
#or do so manually:
  setwd("/Users/kflow/Desktop/Distance mapping")
  getwd()

#load libraries
  library(sf)
  library(dplyr)

#import data
  ##you can convert .kmz files to shapefiles online, 
  ##e.g., here: https://mygeodata.cloud or simply use QGIS
  mangroves <- st_read("Cissell.shp") #from Cissell et al. 2020 https://www.mdpi.com/2076-3417/11/9/4258#app1-applsci-11-04258
  rivers <- st_read("Belize_Rivers.shp") #from J.C. Meerman 2015 http://www.biodiversity.bz 
  llsets <- read.csv("SetCoords.csv") 

#get geometry convert points to sf (WGS84)
  llsetcoords <- st_as_sf(llsets, coords=c("start.long","start.lat"), crs=4326, remove = F)

#project to UTM 16N metres
  llsetcoords_utm <- st_transform(llsetcoords, 32616)
  mangroves_utm <- st_transform(mangroves, 32616)
  rivers_utm <- st_transform(rivers, 32616)

#vizcheck
  plot(st_geometry(mangroves_utm), col = "darkgreen")
  plot(st_geometry(llsetcoords_utm), add = TRUE, pch = 19, col = "purple")

  plot(st_geometry(rivers_utm), col = "blue")
  plot(st_geometry(llsetcoords_utm), add = TRUE, pch = 19, col = "purple")

  bbox_points <- st_bbox(llsetcoords_utm) #zoom in to points only

  plot(st_geometry(mangroves_utm), col = "darkgreen",
     xlim = c(bbox_points["xmin"], bbox_points["xmax"]),
     ylim = c(bbox_points["ymin"], bbox_points["ymax"]))
  plot(st_geometry(llsetcoords_utm), add = TRUE, pch = 19, col = "purple")

  plot(st_geometry(rivers_utm), col = "blue",
     xlim = c(bbox_points["xmin"], bbox_points["xmax"]),
     ylim = c(bbox_points["ymin"], bbox_points["ymax"]))
  plot(st_geometry(llsetcoords_utm), add = TRUE, pch = 19, col = "purple")

#calculate distance
  ##nearest mangroves (m)
  nearest_idx_mang <-st_nearest_feature(llsetcoords_utm, mangroves_utm)
  llsetcoords_utm$dist.mang <- as.numeric (st_distance (llsetcoords_utm,
                                                        mangroves_utm[nearest_idx_mang, ],
                                                        by_element = T))
  ##nearest river (m)
  nearest_idx_riv <-st_nearest_feature(llsetcoords_utm, rivers_utm)
  llsetcoords_utm$dist.riv <- as.numeric (st_distance (llsetcoords_utm,
                                                       rivers_utm[nearest_idx_riv, ],
                                                       by_element = T))

#get rid of geometry column
  llsetcoords_df<-llsetcoords_utm %>% st_drop_geometry()

#export to csv
  write.csv(llsetcoords_df,file = "LLSitesDistances.csv", row.names = FALSE)
