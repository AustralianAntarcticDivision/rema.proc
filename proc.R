#' REMA tile name from file
#'
#' This is the two-part two digit grid e.g. '33_27'.
#'
#' This exists in `raadtools::read_rema_tiles()$tile`, but might be version specific so we
#' use the actual file name with text-proc.
#'
#' @param x filename of a rema tile
get_tile_name <- function(x) unlist(lapply(strsplit(basename(x), "_"), function(xx) paste(xx[1:2], collapse = "_")))


#' Convenience functions to offset a tile extent by its resolution, hardcoded.
#' @param raster or extent object of a tile
ext_to_te200 <- function(x) {
  ## we can't trust extent(x) + val atm
  ##https://github.com/rspatial/raster/issues/206
  xx <- extent(x)

  ## so add it here
  sprintf("-te %f %f %f %f", raster::xmin(xx) - 200, raster::ymin(xx) - 200,
          raster::xmax(xx) + 200, raster::ymax(xx) + 200)
}
#' Convenience functions to offset a tile extent by its resolution, hardcoded.
#' @param raster or extent object of a tile
ext_to_te100 <- function(x) {
  sprintf("-te %f %f %f %f", raster::xmin(x) - 100, raster::ymin(x) - 100,
          raster::xmax(x) + 100, raster::ymax(x) + 100)
}
#' Convenience function, resolution to 'target resolution' of 'gdalwarp -tr'
#' @param raster object
res_to_tr <- function(x) {
  sprintf("-tr %f %f", raster::res(x)[1], raster::res(x)[2])
}
#' Create a closure (get the extent of ith tile)
#' @param files files to be used, we'll ask for the i-th one
mk_get_tile_extent <- function(files) {
  function(i) {
    raster::extent(raster::raster(files$fullname[i]))
  }
}

library(dplyr)
library(raster)
#rfiles <- raadfiles::rema_8m_files()
## cache not up to date so cheat for now
rfiles <- tibble::tibble(fullname =
                           fs::dir_ls(dirname(dirname(raadfiles::rema_8m_files()$fullname[1])),
                     recurse = TRUE, regexp = ".*8m_dem.tif$")
)
#' Function as closure around file names get the extent of ith tile
get_tile_extent <- mk_get_tile_extent(rfiles)

geoidfile <- "02_geoid_height/geoid.vrt"
file_200m <- raadfiles::rema_200m_files()$fullname
file_100m <- raadfiles::rema_100m_files()$fullname

## write the CRS to a file, used by gdalwarp cmd line
writeLines(sf::st_crs("EPSG:3031")$wkt, "srs_def")

## we have special-case write-access here
raadroot <- "/rdsi/PRIVATE/raad2/data_local/aad.gov.au/rema/processing/v1.1"

for (i in 1:nrow(rfiles)) {
  tilename <- get_tile_name(rfiles$fullname[i])
  root <- file.path(raadroot, "200m", tilename)
  fs::dir_create(root)
  out.tif <- file.path(root, gsub("8m_dem", "200m_filled_geoid", basename(rfiles$fullname[i])))
  slope.tif <- file.path(root, gsub("8m_dem", "200m_slope", basename(rfiles$fullname[i])))
  aspect.tif <- file.path(root, gsub("8m_dem", "200m_aspect", basename(rfiles$fullname[i])))
  rugosity.tif <- file.path(root, gsub("8m_dem", "200m_rugosity", basename(rfiles$fullname[i])))

  g <- glue::glue("gdalwarp {geoidfile} {file_200m} {ext_to_te200(get_tile_extent(i))} {res_to_tr(raster::raster(file_200m))} -t_srs srs_def  {out.tif} -co COMPRESS=DEFLATE -r bilinear")
  s <- glue::glue("gdaldem slope {out.tif} {slope.tif}")
  a <- glue::glue("gdaldem aspect {out.tif} {aspect.tif}")
  ru <- glue::glue("gdaldem TRI {out.tif} {rugosity.tif}")

unlink(out.tif)
  if (!file.exists(out.tif)) system(g)
  if (!file.exists(slope.tif)) system(s)
  if (!file.exists(aspect.tif)) system(a)
  if (!file.exists(rugosity.tif)) system(ru)

}




for (i in 1:nrow(rfiles)) {
  tilename <- get_tile_name(rfiles$fullname[i])
  root <- file.path(raadroot, "100m", tilename)
  fs::dir_create(root)

  out.tif <- file.path(root, gsub("8m_dem", "100m_filled_geoid", basename(rfiles$fullname[i])))
  slope.tif <- file.path(root, gsub("8m_dem", "100m_slope", basename(rfiles$fullname[i])))
  aspect.tif <- file.path(root, gsub("8m_dem", "100m_aspect", basename(rfiles$fullname[i])))
  rugosity.tif <- file.path(root, gsub("8m_dem", "100m_rugosity", basename(rfiles$fullname[i])))

  g <- glue::glue("gdalwarp {geoidfile} {file_200m} {file_100m} {ext_to_te100(get_tile_extent(i))} {res_to_tr(raster::raster(file_100m))} -t_srs srs_def  {out.tif} -co COMPRESS=DEFLATE  -r bilinear")
  s <- glue::glue("gdaldem slope {out.tif} {slope.tif}")
  a <- glue::glue("gdaldem aspect {out.tif} {aspect.tif}")
  ru <- glue::glue("gdaldem TRI {out.tif} {rugosity.tif}")

  if (!file.exists(out.tif)) system(g)
  if (!file.exists(slope.tif)) system(s)
  if (!file.exists(aspect.tif)) system(a)
  if (!file.exists(rugosity.tif)) system(ru)
}




