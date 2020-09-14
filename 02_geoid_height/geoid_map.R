geoid <- readAll(raster::raster("~/Git/potato/data-raw/world_geoid/geoid.vrt"))
#extent(geoid) <- extent(-180, 180, -90, 90)
target <- readAll(raadtools::readtopo("rema_1km"))
#res(target) <- 1000
polar_geoid <- projectRaster(geoid, target)
saveRDS(readAll(polar_geoid), "~/Git/rema.proc/polar_geoid.tif")
