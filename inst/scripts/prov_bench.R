library(tidyverse)

process_single_file <- function(file_path, tumor_type = "TCGA_ACC") {
    df <- read_csv(file_path, show_col_types = FALSE)
    print(file_path)
    embedding <- df$last_layer_embed[1] %>%
        str_remove_all("tensor\\(\\[\\[|\\]\\]\\)") %>%
        str_remove_all("\n") %>%
        str_squish() %>%
        str_split(",\\s*") %>%
        unlist() %>%
        as.numeric()
    tibble(
        slide_name = df$slide_name[1],
        tumor_type = tumor_type,
        !!!set_names(as.list(embedding), paste0("V", seq_along(embedding)))  # Colonne V1, V2, V3, ...
    )
}

prov_url <- paste0(
    "https://store.cancerdatasci.org/provgigapath/slide_level/",
    "TCGA_ACC/",
    "TCGA-OR-A5JJ-01Z-00-DX1.459B5DFE-47B1-426F-B009-7664C1B6FEEC.csv.gz"
)
prov_file <- file.path(tempdir(), basename(prov_url))
download.file(prov_url, destfile = prov_file)

microbenchmark::microbenchmark({
    ProvGiga(prov_file, tumorType = "TCGA_ACC") |> import()
}, {
    process_single_file(prov_file)
},times = 10L
)

## Unit: milliseconds
## expr       min        lq      mean    median
## {     import(ProvGiga(prov_file, tumorType = "TCGA_ACC")) }  37.07123  37.78003  38.24495  37.97677
## {     process_single_file(prov_file) } 144.27608 146.32801 152.96790 147.48891
## uq       max neval cld
## 38.33456  40.58436    10  a
## 155.07389 184.01152    10   b
