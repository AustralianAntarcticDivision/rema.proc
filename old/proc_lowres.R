library(raadtools)
geoid <- readAll(raster::raster("02_geoid_height/polar_geoid.tif"))
angle_normalise <- function(x) (x+pi)%%(2*pi)-pi ## normalize angle in radians to range [-pi,pi)

## aspect is given relative to the (projected) grid, so we need to adjust by longitude to get compass aspect
longitude_all <- function(x) {
  sf::sf_project(projection(x),  to = "+proj=longlat", xyFromCell (x, 1:ncell(x)))[,1L]
}

kms <- c("1km", "200m", "100m")
remas <- c("rema_1km", "rema_200m", "rema_100m")
outdir <- "/rdsi/PRIVATE/raad/data_local/aad.gov.au/rema/rema.proc_lowres"
patt <- "REMA_%s_dem_%s.tif"
for (i in 2:3) {

dem <- readAll(raadtools::readtopo(remas[i]))
## try by scanline
vvv <- cells <- vector("list", nrow(dem))

 for (line in seq_len(nrow(dem))) {
  cell <- cellFromRow(dem, line)
  bad <- is.na(extract(dem, cell))
  if (any(bad)) {
    cells[[line]] <- cell[bad]
    vvv[[line]] <- extract(geoid, xyFromCell(dem, cell[bad]), method = "bilinear")
  }
  if (line %% 100 == 0) print(line)
 }
 dem@data@values[unlist(cells)] <- unlist(vvv)
rm(cells, vvv, cell, bad)
slp <- terrain(dem, "slope", filename = file.path(outdir, sprintf(patt, kms[i], "slope")))
tri <- terrain(dem, "TRI", filename = file.path(outdir, sprintf(patt, kms[i], "TRI")))
asp <- terrain(dem, "aspect")
writeRaster(dem, filename = file.path(outdir, sprintf(patt, kms[i], "geoid")))
rm(dem)
asp <- setValues(asp, angle_normalise(angle_normalise(raster::values(asp))  - ## normalise to -pi,pi
                                            longitude_all(asp) / 180 * pi))
writeRaster(asp, filename = file.path(outdir, sprintf(patt, kms[i], "aspect")))
rm(asp)
gc()
gc()

}


