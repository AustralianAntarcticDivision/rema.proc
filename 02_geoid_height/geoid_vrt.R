#files <- raadfiles::get_raad_filenames()
#grep("n00w180", files$file)
library(dplyr)
files <- raadfiles::get_raad_filenames(all = TRUE) %>%
  filter(stringr::str_detect(file, "earth-info.nga.mil/GandG/wgs84/gravitymod/egm2008/.*w001001.adf$")) %>%
  transmute(fullname = file.path(root, file))

geoid.vrt <- "02_geoid_height/geoid.vrt"
system(sprintf("gdalbuildvrt %s %s", geoid.vrt, paste0(files$fullname, collapse = " ")))
raster::raster(geoid.vrt)



