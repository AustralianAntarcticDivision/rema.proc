rema_rock_polygon_files <- function() {
  raadfiles::get_raad_filenames(all = TRUE) %>%
    dplyr::filter(grepl("add_rock_outcrop_medium_res_polygon_v7.3.gpkg", file)) %>%
    dplyr::transmute(fullname = file.path(root, file))
}

get_tile_name <- function(x) unlist(lapply(strsplit(basename(x), "_"), function(xx) paste(xx[1:2], collapse = "_")))
rema_rock_raster_files <- function() {
  library(dplyr)
   raadfiles::get_raad_filenames(all = TRUE) %>%
    dplyr::filter(grepl("data_local", root)) %>%
    dplyr::filter(grepl(".*v1.1.*_8m_rock.tif", file)) %>%
     dplyr::transmute(fullname = file.path(root, file))
}
rema_rock_raster_files <- memoise::memoize(rema_rock_raster_files)

rema_rock_tiles <- function() {
  readRDS("/rdsi/PRIVATE/raad/data_local/aad.gov.au/rema/processing/polytiles_rock.rds")
}
tiles <- rema_rock_tiles()

library(sp)
plot(tiles, col = palr::d_pal(tiles$hasrock))
files <- rema_rock_raster_files() %>% mutate(tile = get_tile_name(fullname)) %>% inner_join(as.data.frame(tiles) %>% dplyr::transmute(tile, rema_file = fullname), "tile")
files$xmin <- files$xmax <- files$ymin <- files$ymax <- 0

for (i in seq_len(nrow(files))) {
  r <- raster::raster(files$rema_file[i])
 files$xmin[i] <- raster::xmin(r)
 files$xmax[i] <- raster::xmax(r)
 files$ymin[i] <- raster::ymin(r)
 files$ymax[i] <- raster::ymax(r)
}

i <- 1
vrt <- function(ex) {
  ex <- raster::extent(ex)
  xmin <- raster::xmin(ex)
  xmax <- raster::xmax(ex)
  ymin <- raster::ymin(ex)
  ymax <- raster::ymax(ex)

  src <- "/rdsi/PUBLIC/raad/data/ftp.data.pgc.umn.edu/elev/dem/setsm/REMA/mosaic/v1.1/200m/REMA_200m_dem_filled.tif"
  tfile <- tempfile(fileext = ".vrt")
  system(sprintf("gdal_translate %s %s -of VRT -projwin %f %f %f %f", src, tfile, xmin, ymax, xmax, ymin))
  tfile
}
rema_tile <- vrt(c(files$xmin[i], files$xmax[i], files$ymin[i], files$ymax[i]))
tile <- files$tile[i]
slopecall <- glue::glue("gdaldem slope {rema_tile} /rdsi/PRIVATE/raad/data_local/aad.gov.au/rema/processing/v1.1/8m/{tile}/{tile}_200m_slope.tif ")
aspcall <- glue::glue("gdaldem aspect {rema_tile} /rdsi/PRIVATE/raad/data_local/aad.gov.au/rema/processing/v1.1/8m/{tile}/{tile}_200m_aspect.tif ")
