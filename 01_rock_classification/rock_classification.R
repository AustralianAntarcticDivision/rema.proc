## we use https://data.bas.ac.uk/items/077e1f04-7068-4327-a4f2-71d863f70064/

## Medium resolution vector polygons of Antarctic rock outcrop version 7.3

## "good compromise between detail and conservatism"

# https://data.bas.ac.uk/download/fe90d6aec-b53e-40c1-ad52-c05e03a58c1d


library(raadtools)
library(fasterize)

rocklayer <- "/rdsi/PRIVATE/raad/data_local/aad.gov.au/rema/processing/add_rock_outcrop_medium_res_polygon_v7.3.gpkg"
rock <- sf::read_sf(rocklayer)


files <- raadfiles::rema_8m_files()
files$tile <- basename(dirname(files$fullname))
polytiles <- raadtools::read_rema_tiles()
polytiles$fullname <- files$fullname[match(polytiles$tile, files$tile)]
polytiles$hasrock <- FALSE
polytiles$size <- 0

hasrock <- polytiles$hasrock
size <- polytiles$size

## this was run locally, and then moved into the data_local//8m/ folders
raadroot <- "/rdsi/PRIVATE/raad/data_local/aad.gov.au/rema/processing/v1.1"
polytiles$outfile <- file.path(raadroot, basename(dirname(polytiles$fullname)), gsub("dem", "rock", basename(polytiles$fullname)))


for (i in seq_len(nrow(polytiles))) {
     r <- raster(polytiles$fullname[i])
     p <- fasterize(rock, r)

     test <- !all(is.na(values(p)))

     hasrock[i] <- test
     if (test) {

       writeRaster(p, polytiles$outfile[i], options = c(COMPRESS = "DEFLATE", SPARSE_OK="NO"), datatype = "INT1U", overwrite = TRUE)
       size[i] <- file.info(polytiles$outfile[i])$size

      writeLines(as.character(i), "logfile")

     }
     rm(r, p)
    }

polytiles$hasrock <- hasrock
polytiles$size <- size
saveRDS(polytiles, "01_rock_classification/polytiles_rock_8m.rds")



## now 200m
rockfiles <- tibble::tibble(fullname = fs::dir_ls(file.path(raadroot, "200m"), regexp = "filled_geoid.*tif$", recurse = TRUE))
rockfiles$hasrock <- FALSE
rockfiles$size <- 0

raadroot <- "/rdsi/PRIVATE/raad2/data_local/aad.gov.au/rema/processing/v1.1/200m"
rockfiles$outfile <- file.path(raadroot, basename(dirname(rockfiles$fullname)), gsub("filled_geoid", "rock", basename(rockfiles$fullname)))


for (i in seq_len(nrow(rockfiles))) {
  r <- raster(rockfiles$fullname[i])
  p <- fasterize(rock, r)

  test <- !all(is.na(values(p)))

  rockfiles$hasrock[i] <- test
  if (test) {

    writeRaster(p, rockfiles$outfile[i], options = c(COMPRESS = "DEFLATE", SPARSE_OK="NO"), datatype = "INT1U", overwrite = FALSE)
    rockfiles$size[i] <- file.info(rockfiles$outfile[i])$size

  }
  rm(r, p)
  print(i)
}
## do this properly as part of raadtools scan
saveRDS(rockfiles, "01_rock_classification/rockfiles_rock_200m.rds")



## now 100m
raadroot <- "/rdsi/PRIVATE/raad2/data_local/aad.gov.au/rema/processing/v1.1"

rockfiles <- tibble::tibble(fullname = fs::dir_ls(file.path(raadroot, "100m"), regexp = "filled_geoid.*tif$", recurse = TRUE))
rockfiles$hasrock <- FALSE
rockfiles$size <- 0

rockfiles$outfile <- file.path(raadroot, "100m", basename(dirname(rockfiles$fullname)), gsub("filled_geoid", "rock", basename(rockfiles$fullname)))


for (i in seq_len(nrow(rockfiles))) {
  r <- raster(rockfiles$fullname[i])
  p <- fasterize(rock, r)

  test <- !all(is.na(values(p)))

  rockfiles$hasrock[i] <- test
  if (test) {

    writeRaster(p, rockfiles$outfile[i], options = c(COMPRESS = "DEFLATE", SPARSE_OK="NO"), datatype = "INT1U", overwrite = FALSE)
    rockfiles$size[i] <- file.info(rockfiles$outfile[i])$size

  }
  rm(r, p)
  print(i)
}

saveRDS(rockfiles, "01_rock_classification/rockfiles_rock_100m.rds")


## now 1km

file_1km <- raadfiles::rema_1km_files()$fullname

r <- raster(file_1km)
p <- fasterize(rock, r)
writeRaster(p, file.path(raadroot, "1km", "REMA_1km_rock.tif"),
            options = c(COMPRESS = "DEFLATE", SPARSE_OK="NO"), datatype = "INT1U", overwrite = FALSE)

