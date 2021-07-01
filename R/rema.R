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
ext_to_te8 <- function(x) {
  ## we can't trust extent(x) + val atm
  ##https://github.com/rspatial/raster/issues/206
  xx <- extent(x)

  ## so add it here
  sprintf("-te %f %f %f %f", raster::xmin(xx) - 8, raster::ymin(xx) - 8,
          raster::xmax(xx) + 8, raster::ymax(xx) + 8)
}

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

#' Convenience functions to offset a tile extent by its resolution, hardcoded.
#' @param raster or extent object of a tile
ext_to_te1000 <- function(x) {
  sprintf("-te %f %f %f %f", raster::xmin(x) - 1000, raster::ymin(x) - 1000,
          raster::xmax(x) + 1000, raster::ymax(x) + 1000)
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
