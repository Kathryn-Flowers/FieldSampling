######Generating random coordinates within a polygon#####
 
#Author: Katie Flowers
#Date last modified: 22 July 2025

#####-----------------------------------------------#####

#install packages you don't have already
install.packages("sf") #for random point generation
install.packages("leaflet") #if you want a basemap

#####-----------------------------------------------#####

#set your working directory however you choose
  #from dropdown menu: Session > Set Working Directory > Choose Directory
  #or do so manually:
    setwd("/Users/kflow/Downloads/mygeodata")
    getwd()

#load libraries
  library(sf)
  library(leaflet)

#import shapefile
  ##you can convert .kmz files to shapefiles online, 
  ##e.g., here: https://mygeodata.cloud 
  ##my shapefile was called TestPolygon
    CapeEnrage <- read_sf(dsn = ".", layer = "TestPolygon")
    
#fix random number generator output 
    ##do this to keep same random points every time you rerun code
    ##DON'T do this if you need a new set of random points for your next season/year of sampling
      set.seed(90) #choose any integer it sets the starting point for consistency

#generate your random coordinates
  ##note that it samples without replacement from continuous surface
  ##you can update number of points from 30 to whatever you need
    RandomPoints <- st_sample(CapeEnrage, size = 30, type = "random") 

#convert to sf object
  RandomPointsSF <- st_sf(geometry = RandomPoints)

#plot the points to verify
  plot(st_geometry(CapeEnrage), col = NA, border = 'black')
  plot(RandomPointsSF, col = 'purple', pch = 16, add = TRUE)
  
#extract your coordinates if you want to export to csv and for Google Earth
  Coordinates <- st_coordinates(RandomPointsSF) 
  Coordinates

#prep to export making three columns: 
  CoordinatesData <- data.frame(id = 1:30, #one for id number
                                lat = Coordinates[, 2], #one for latitude
                                long = Coordinates[, 1]) #one for longitude
  CoordinatesData
  
#export to csv 
  write.csv(CoordinatesData, "CapeEnrangeCoords.csv", row.names = FALSE)
  
#if you want points labelled for direct import to Google Earth
  Coords_ID <- st_as_sf(CoordinatesData, coords = c("long", "lat"), crs = 4326) #4326 = WGS84
  Coords_ID$Name <- as.character(Coords_ID$id) #make sure id = Name for Google Earth to recognize id numbers
  Coords_ID$id <- NULL #get rid of old column name in case things get wild
  st_write(Coords_ID, "CapeEnrangeCoordinates.kml", driver = "KML") #use append=FALSE if you need to rerun this
  
#you can also add a basemap in R for direct viewing
#check to make sure CapeEnrage [your location] in lat/long
  CapeEnrage <- st_transform(CapeEnrage, 4326) #4326 = WGS84
  
#add the ID numbers to sf point object
  RandomPointsSF$id <- 1:nrow(RandomPointsSF)
  
#convert sf objects for leaflet
  Map <- leaflet() %>%
    addProviderTiles(providers$Esri.WorldImagery) %>% #satellite basemap
    addPolygons(data = CapeEnrage, #what your polygon will look like
                color = "black", #polygon outline
                weight = 2, #outline thickness
                fillOpacity = 0.2) %>% #how transparent your fill will be
    addCircleMarkers(data = RandomPointsSF, #what your points will look like
                     radius = 2, #point size
                     color = "purple", #point colour
                     fill = TRUE, #point fill yes=TRUE, no=FALSE
                     fillOpacity = 1, #how transparent your points are (1 = not at all)
                     label = ~as.character(id),  #show ID number when hovering mouse
                     labelOptions = labelOptions(noHide = FALSE, #if this is set to TRUE numbers will stay fixed on map
                                                 direction = "right", 
                                                 textsize = "10px", 
                                                 offset = c(5,0)))
                     
#view your map and its sources!
  Map
  