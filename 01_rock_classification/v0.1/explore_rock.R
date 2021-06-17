
reprex::reprex({
  ## which files have most rock?
library(sp)
f <- tibble::tibble(file =  fs::dir_ls("/perm_storage/home/mdsumner/Git/rema.proc/rockraster"),
                    size = fs::file_info(file)$size)
f$tile <- substr(basename(f$file), 1, 5)
poly_tiles <- readRDS("/perm_storage/home/mdsumner/Git/rema.proc/polytiles_rock.rds")
plot(poly_tiles[match(f$tile, poly_tiles$tile), ], col = colourvalues::colour_values(f$size))
})

