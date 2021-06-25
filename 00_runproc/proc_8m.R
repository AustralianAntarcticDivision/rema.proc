source("R/rema.R")


library(dplyr)
library(raster)
#rfiles <- raadfiles::rema_8m_files()
## cache not up to date so cheat for now
## we only want the ROCK files
rfiles <- tibble::tibble(fullname =
                           fs::dir_ls(dirname(dirname(raadfiles::rema_8m_files()$fullname[1])),
                                      recurse = TRUE, regexp = ".*8m_dem.tif$")
)

rfiles$tile <- get_tile_name(rfiles$fullname)
rocktiles <- readRDS("01_rock_classification/polytiles_rock_8m.rds")
ok <- rfiles$tile %in% rocktiles$tile[rocktiles$hasrock]
rfiles <- rfiles[ok, ]

#' Function as closure around file names get the extent of ith tile
get_tile_extent <- mk_get_tile_extent(rfiles)

geoidfile <- "02_geoid_height/geoid.vrt"
file_200m <- raadfiles::rema_200m_files()$fullname
#file_100m <- raadfiles::rema_100m_files()$fullname

## write the CRS to a file, used by gdalwarp cmd line
writeLines(sf::st_crs("EPSG:3031")$wkt, "srs_def")

## we have special-case write-access here
raadroot <- "/rdsi/PRIVATE/raad2/data_local/aad.gov.au/rema/processing/v1.1"

for (i in 1:nrow(rfiles)) {
  tilename <- get_tile_name(rfiles$fullname[i])
  root <- file.path(raadroot, "8m", tilename)
  fs::dir_create(root)
  out.tif <- file.path(root, gsub("8m_dem", "8m_filled_geoid", basename(rfiles$fullname[i])))
  slope.tif <- file.path(root, gsub("8m_dem", "8m_slope", basename(rfiles$fullname[i])))
  aspect.tif <- file.path(root, gsub("8m_dem", "8m_aspect", basename(rfiles$fullname[i])))
  rugosity.tif <- file.path(root, gsub("8m_dem", "8m_rugosity", basename(rfiles$fullname[i])))

  thedemfile <- rfiles$fullname[i]
  g <- glue::glue("gdalwarp {geoidfile} {file_200m} {thedemfile} {ext_to_te8(get_tile_extent(i))} {res_to_tr(raster::raster(thedemfile))} -t_srs srs_def  {out.tif} -co COMPRESS=LZW -co TILED=YES -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 -r bilinear")
  s <- glue::glue("gdaldem slope {out.tif} {slope.tif}")
  a <- glue::glue("gdaldem aspect {out.tif} {aspect.tif}")
  ru <- glue::glue("gdaldem TRI {out.tif} {rugosity.tif}")


  if (!file.exists(out.tif)) system(g)
  if (!file.exists(slope.tif)) system(s)
  if (!file.exists(aspect.tif)) system(a)
  if (!file.exists(rugosity.tif)) system(ru)
print(i)
}




