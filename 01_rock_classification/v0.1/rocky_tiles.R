f <- tibble::tibble(file =  fs::dir_ls("rockraster"),
                    size = fs::file_info(file)$size)
f$tile <- substr(basename(f$file), 1, 5)
poly_tiles <- subset(readRDS("polytiles_rock.rds"), hasrock)
poly_tiles$rocksize <- fs::file_info(f$file)$size[match(poly_tiles$tile, f$tile)]

library(dplyr)
poly_tiles <- poly_tiles[order(poly_tiles$rocksize, decreasing = TRUE), ]
library(lazyraster)
#tile <- as_raster(lazyraster(poly_tiles$fullname[which.max(poly_tiles$rocksize)]))


pdf("atlas.pdf", onefile = TRUE)
par(mar = c(0, 0, 4.1, 2.1))
for (i in 1:20) {
  tile <- as_raster(lazyraster(poly_tiles$fullname[i]))

  w <- wk::new_wk_wkb(
  vapour::vapour_read_geometry("add_rockoutcrop_landsat_v7.2.shp", layer = 0,
                                   sql = "SELECT * FROM \"add_rockoutcrop_landsat_v7.2\"",
                             extent = c(xmin(tile), xmax(tile), ymin(tile), ymax(tile)))
  )

  plot(tile, col = grey.colors(64), axes = FALSE)

title(poly_tiles$tile[i])
  plot(w, add = TRUE, border = "firebrick")  ## requires wkutils
}
dev.off()
