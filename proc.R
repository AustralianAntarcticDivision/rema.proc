library(raadtools)
vrast <- raadtools::readtopo("rema_8m")
rock_shp <- "01_rock_classification/add_rockoutcrop_landsat_v7.2.shp"
#dist <- readAll(raster::raster("03_distance_coast/rema_distcoast_1km.tif"))
geoid <- readAll(raster::raster("02_geoid_height/polar_geoid.tif"))
angle_normalise <- function(x) (x+pi)%%(2*pi)-pi ## normalize angle in radians to range [-pi,pi)

## aspect is given relative to the (projected) grid, so we need to adjust by longitude to get compass aspect
longitude <- function(x) {
  sf::sf_project(projection(x),  to = "+proj=longlat", xyFromCell (x, cellFromRowCol(x, nrow(x)/2, ncol(x)/2)))[,1L]
}


poly_tiles <- readRDS("polytiles_rock.rds")
poly_tiles$geoid_fill <- NA_real_
rasterOptions(maxmemory = 1e11)
outdir <- "/rdsi/PRIVATE/raad/data_local/aad.gov.au/rema/rema.proc"
library(terra)
cnt <- 0
for (i in seq_len(nrow(poly_tiles))) {
  if (poly_tiles$hasrock[i]) {


    tile <- extend(raster(raster(poly_tiles$fullname[i])), 2)
    #sfx <- sf::read_sf(rock_shp, wkt_filter =  sf::st_as_text(sf::st_as_sfc(sf::st_bbox(tiny_tile))))
    #rock_tile <- fasterize::fasterize(sfx, tiny_tile)
    outfile <- file.path(outdir, sprintf("%s_fill.tif", gsub(".tif", "", basename(poly_tiles$fullname[i]))))
    if (file.exists(outfile)) next;

    demvals <- vapour::vapour_warp_raster(filename(vrast), bands = 1L, extent = extent(tile), dimension = dim(tile)[2:1])[[1L]]
    eheight <- mean(extract(geoid, cellsFromExtent(geoid, extent(tile))))
    poly_tiles$geoid_fill[i] <- eheight
    demvals[is.na(demvals)] <- eheight
    dem <- setValues(tile, demvals)
    rm(demvals)

    slp <- terrain(dem, "slope")
    asp <- terrain(dem, "aspect")
    tri <- terrain(dem, "TRI")
    #dtc <- setValues(dem, extract(dist, xyFromCell(dem, seq_len(ncell(dem))), method = "bilinear"))

    asp <- setValues(asp, angle_normalise(angle_normalise(raster::values(asp))  - ## normalise to -pi,pi
                                            longitude(asp) / 180 * pi))

    xx <- c(rast(dem), rast(slp), rast(asp), rast(tri))
    names(xx) <- c("rema", "slope", "aspect", "TRI")

    writeRaster(xx, outfile, names = c("rema", "slope", "aspect", "TRI"))
    rm(xx, dem, slp, asp, tri)
    cnt <- cnt + 1
    if (cnt > 50) {
      print("ending session, 50 done")
      break;
    }
  }
}

















#
#
#
#
#
#
#     index <- raster(extent(tile), nrows = 4, ncols = 4)
#
#     for (j in seq_len(ncell(index))) {
#       tiny_tile <- extend(raster(extentFromCells(index, j), res = res(tile)), 2L)
#       sfx <- sf::read_sf(rock_shp, wkt_filter =  sf::st_as_text(sf::st_as_sfc(sf::st_bbox(tiny_tile))))
#       if (nrow(sfx) < 1) next;
#
#       rock_tile <- fasterize::fasterize(sfx, tiny_tile)
#
#       if (!all(is.na(values(rock_tile)))) {
#         outfile <- sprintf("proc/%s_j%02i.tif", gsub(".tif", "", basename(poly_tiles$fullname[i])), j)
#         if (file.exists(outfile)) next;
#         dem0 <- readAll(crop(vrast, rock_tile))
#         dem <- dem0
#         eheight <- mean(extract(geoid, cellsFromExtent(geoid, extent(dem))))
#         dem[is.na(dem)] <- eheight
#
#
#         slp <- terrain(dem, "slope")
#         asp <- terrain(dem, "aspect")
#         tri <- terrain(dem, "TRI", sprintf("TRI_%04i.tif", poly_tiles$tile_index[i]))
#         dtc <- setValues(dem, extract(dist, xyFromCell(dem, seq_len(ncell(dem))), method = "bilinear"))
#
#         asp <- setValues(asp, angle_normalise(angle_normalise(raster::values(asp))  - ## normalise to -pi,pi
#                                                 longitude(asp) / 180 * pi))
#
#         xx <- c(rast(dem0), rast(dem), rast(slp), rast(asp), rast(tri), rast(dtc))
#         writeRaster(xx, outfile)
#         rm(xx, dem0, dem, slp, asp, tri, dtc)
#
#       }
#       }
#
#     }
#   }
