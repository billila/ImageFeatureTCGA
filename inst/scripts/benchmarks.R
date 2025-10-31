# timings for functions

# HoverJSON
hov_json_file <- system.file(
    "extdata",
    "TCGA-J4-A6M7-01Z-00-DX1.0B8011EA-86D2-4439-B8AA-C6EC3D5985A0.json",
    mustWork = TRUE,
    package = "ImageFeatureTCGA"
)

HoverJSON(hov_json_file) |> import()
## 42.97212 secs

# json_to_SpatialExperiment
json_file <- system.file(
    "extdata",
    "TCGA-J4-A6M7-01Z-00-DX1.0B8011EA-86D2-4439-B8AA-C6EC3D5985A0.json",
    mustWork = TRUE,
    package = "ImageFeatureTCGA"
)

json_to_SpatialExperiment(json_file)
## 325.0974 secs
