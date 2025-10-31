# timings for functions
library(ImageFeatureTCGA)

hov_json_file <- paste0(
    "https://store.cancerdatasci.org/hovernet/TCGA_OV/json/",
    "TCGA-23-1121-01Z-00-DX1.E2F25441-32C3-46BF-A845-CB4FA787E8CB.json.gz"
)
dest_json <- file.path(tempdir(), basename(hov_json_file))
download.file(hov_json_file, destfile = dest_json)

# HoverJSON
microbenchmark::microbenchmark(
    HoverJSON(dest_json) |> import(),
    times = 1L
)
## 42.97212 secs

# json_to_SpatialExperiment
microbenchmark::microbenchmark(
    json_to_SpatialExperiment(dest_json),
    times = 1L
)
## 325.0974 secs
