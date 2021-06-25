library(raadfiles)
funs <- list(REMA_100m_dem_geoid = rema_100m_dem_geoid_files,
             REMA_100m_slope = rema_100m_slope_files,
             REMA_100m_aspect = rema_100m_aspect_files,
             REMA_100m_rugosity = rema_100m_rugosity_files,

             REMA_200m_dem_geoid = rema_200m_dem_geoid_files,
             REMA_200m_slope = rema_200m_slope_files,
             REMA_200m_aspect = rema_200m_aspect_files,
             REMA_200m_rugosity =  rema_200m_rugosity_files)

build_and_burn <- function(x) {
  root <- "/rdsi/PRIVATE/raad2/data_local/aad.gov.au/rema/processing/v1.1/untiled"
  files <- x[[1]]()$fullname
  name <- names(x[1])
  temp.vrt <- tempfile(fileext = ".vrt")
  inputfilelist <- tempfile(fileext = ".list")
  out.tif <- file.path(root, sprintf("%s.tif", name))

  writeLines(files, inputfilelist)
  todo <- glue::glue("gdalbuildvrt -input_file_list {inputfilelist} {temp.vrt}")
  system(todo)
  towarp <- glue::glue("gdalwarp {temp.vrt} {out.tif}  -co COMPRESS=LZW -co TILED=YES -co BIGTIFF=IF_SAFER -multi -wo NUM_THREADS=16")
  system(towarp)
  c(todo, towarp)
}

ff <- vector("list", length(funs))
for (i in seq_along(funs)) {
  ff[[i]] <- build_and_burn(funs[i])
print(i)
}

print(ff)


