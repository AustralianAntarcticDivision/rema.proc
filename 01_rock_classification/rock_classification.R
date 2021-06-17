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
lf <- list.files("rockraster")
polytiles$outfile <- file.path("rockraster", basename(dirname(polytiles$fullname)), gsub("dem", "rock", basename(polytiles$fullname)))




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
 saveRDS(polytiles, "01_rock_classification/polytiles_rock.rds")
#
