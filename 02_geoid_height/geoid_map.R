library(raster)
geoid <- readAll(raster::raster("~/Git/potato/data-raw/world_geoid/geoid.vrt"))
#extent(geoid) <- extent(-180, 180, -90, 90)
target <- raster(raadtools::readtopo("rema_1km"))
res(target) <- 5000
polar_geoid <- projectRaster(geoid, target)
writeRaster(readAll(polar_geoid), "~/Git/rema.proc/02_geoid_height/polar_geoid.tif")
