## takes ages
#rock <- sf::read_sf("add_rockoutcrop_landsat_v7.2.shp")
#arock <- sf::st_union(st_geometry(rock))
#saveRDS(arock, "rock.rds")
library(raadtools)
library(fasterize)

files <- raadfiles::rema_8m_files()
files$tile <- basename(dirname(files$fullname))
polytiles <- raadtools::read_rema_tiles()
polytiles$fullname <- files$fullname[match(polytiles$tile, files$tile)]
rock <- sf::read_sf("add_rockoutcrop_landsat_v7.2.shp")
polytiles$hasrock <- FALSE


#plot(st_coordinates(st_centroid(rock)), pch = ".")
# i <- sample(1:nrow(polytiles), 1)
# library(basf)
# plot(polytiles[i, ], add = TRUE, border = "red")
#i <- 1339 ## covered in rock

for (i in seq_len(nrow(polytiles))) {
  writeLines(as.character(i), "logfile")

  tile <- polytiles$tile[i]

  r <- raster(polytiles$fullname[i])
  p <- fasterize(rock, r)

  test <- any(!is.na(values(p)))
  polytiles$hasrock[i] <- test
  if (test) {
    file <- gsub("dem", "rock", basename(polytiles$fullname[i]))
    writeRaster(p, glue::glue("rockraster/{file}"), options = c(COMPRESS = "DEFLATE", SPARSE_OK="NO"), datatype = "INT1U")
  }
}
saveRDS(polytiles, "polytiles_rock.rds")

