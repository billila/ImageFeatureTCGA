
# imageFeatureTCGA

``` r
library(imageFeatureTCGA)
library(SummarizedExperiment)
library(dplyr)
```

# Overview

`imageFeatureTCGA` (`imageTCGA`) provides convenient access to
histopathology-derived data from **TCGA** through two complementary
pipelines:

- **HoVerNet** → cell segmentation and classification
- **ProvGigaPath** → slide- and tile-level embeddings

These datasets can be imported directly into R as **Bioconductor
objects**, facilitating downstream integration with TCGA omics and
clinical data.

# Installation

``` r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("waldronlab/imageFeatureTCGA")
```

# Available Data

Use the following function to download the catalog of available files:

``` r
getCatalog()
#> # A tibble: 54,253 × 25
#>    pipeline format  filename  fullpath fnsansext tcga_barcode Case.ID TSS.Code File.ID File.Name
#>    <chr>    <chr>   <chr>     <chr>    <chr>     <chr>        <chr>   <chr>    <chr>   <chr>    
#>  1 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       0de078… TCGA-02-…
#>  2 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       27021a… TCGA-02-…
#>  3 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       6486cb… TCGA-02-…
#>  4 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       cf6cd3… TCGA-02-…
#>  5 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       0c0fbb… TCGA-02-…
#>  6 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       0ea47d… TCGA-02-…
#>  7 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       33e598… TCGA-02-…
#>  8 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       e8c171… TCGA-02-…
#>  9 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       aa05ed… TCGA-02-…
#> 10 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       e9c5af… TCGA-02-…
#> # ℹ 54,243 more rows
#> # ℹ 15 more variables: Data.Category <chr>, Data.Type <chr>, Project.ID <chr>, Sample.ID <chr>,
#> #   Sample.Type <chr>, Source.Site <chr>, Study.Name <chr>, BCR <chr>, city <chr>, state <chr>,
#> #   country <chr>, bcr_patient_uuid <chr>, lat <dbl>, lon <dbl>, level <chr>
```

## Formats

- **HoVerNet** data is available in `JSON`, `GeoJSON`, `thumb` and
  `H5AD` formats.
- **ProvGigaPath** data is available in CSV format.

Note that the `thumb` format refers to the png thumbnails of the
whole-slide images.

### HoVerNet data

``` r
getCatalog("hovernet")
#> # A tibble: 33,177 × 25
#>    pipeline format  filename  fullpath fnsansext tcga_barcode Case.ID TSS.Code File.ID File.Name
#>    <chr>    <chr>   <chr>     <chr>    <chr>     <chr>        <chr>   <chr>    <chr>   <chr>    
#>  1 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       0de078… TCGA-02-…
#>  2 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       27021a… TCGA-02-…
#>  3 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       6486cb… TCGA-02-…
#>  4 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       cf6cd3… TCGA-02-…
#>  5 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       0c0fbb… TCGA-02-…
#>  6 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       0ea47d… TCGA-02-…
#>  7 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       33e598… TCGA-02-…
#>  8 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       e8c171… TCGA-02-…
#>  9 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       aa05ed… TCGA-02-…
#> 10 hovernet geojson TCGA-02-… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02       e9c5af… TCGA-02-…
#> # ℹ 33,167 more rows
#> # ℹ 15 more variables: Data.Category <chr>, Data.Type <chr>, Project.ID <chr>, Sample.ID <chr>,
#> #   Sample.Type <chr>, Source.Site <chr>, Study.Name <chr>, BCR <chr>, city <chr>, state <chr>,
#> #   country <chr>, bcr_patient_uuid <chr>, lat <dbl>, lon <dbl>, level <chr>
```

### ProvGigaPath data

``` r
getCatalog("provgigapath")
#> # A tibble: 21,076 × 25
#>    pipeline   format filename fullpath fnsansext tcga_barcode Case.ID TSS.Code File.ID File.Name
#>    <chr>      <chr>  <chr>    <chr>    <chr>     <chr>        <chr>   <chr>    <chr>   <chr>    
#>  1 provgigap… csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02       0de078… TCGA-02-…
#>  2 provgigap… csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02       27021a… TCGA-02-…
#>  3 provgigap… csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02       6486cb… TCGA-02-…
#>  4 provgigap… csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02       cf6cd3… TCGA-02-…
#>  5 provgigap… csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02       0c0fbb… TCGA-02-…
#>  6 provgigap… csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02       0ea47d… TCGA-02-…
#>  7 provgigap… csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02       33e598… TCGA-02-…
#>  8 provgigap… csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02       e8c171… TCGA-02-…
#>  9 provgigap… csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02       aa05ed… TCGA-02-…
#> 10 provgigap… csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02       e9c5af… TCGA-02-…
#> # ℹ 21,066 more rows
#> # ℹ 15 more variables: Data.Category <chr>, Data.Type <chr>, Project.ID <chr>, Sample.ID <chr>,
#> #   Sample.Type <chr>, Source.Site <chr>, Study.Name <chr>, BCR <chr>, city <chr>, state <chr>,
#> #   country <chr>, bcr_patient_uuid <chr>, lat <dbl>, lon <dbl>, level <chr>
```

# Importing HoVerNet data

You can import HoVerNet segmentation results as either a
`SpatialExperiment` or `SpatialFeatureExperiment`. Here we selectively
import a file based on its filename, but you can also filter by other
metadata fields such as `Project.ID`, `pipeline`, `format`, etc.

``` r
hspe <- getCatalog("hovernet") |>
    dplyr::filter(
        filename == paste(
            "TCGA-VG-A8LO-01A-01-DX1",
            "B39A4D64-82A1-4A04-8AB6-918F3058B83B",
            "json",
            "gz",
            sep = "."
        )
    ) |>
    getFileURLs() |>
    HoverNet(outClass = "SpatialExperiment") |>
    import()
hspe
#> class: SpatialExperiment 
#> dim: 0 67081 
#> metadata(1): type_map
#> assays(1): counts
#> rownames: NULL
#> rowData names(0):
#> colnames: NULL
#> colData names(10): cell_id x ... B sample_id
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
#> spatialCoords names(2) : x y
#> imgData names(0):
```

Each cell is represented with:

- `x`, `y` spatial coordinates
- cell type and type probabilities
- optional contours stored in metadata

``` r
colData(hspe)
#> DataFrame with 67081 rows and 10 columns
#>           cell_id         x         y      type type_prob       label         R         G
#>       <character> <numeric> <numeric> <integer> <numeric> <character> <integer> <integer>
#> 1               8   3894.64   15842.5         1 0.9696429      neopla       255         0
#> 2               9   3920.24   15864.1         1 0.9077253      neopla       255         0
#> 3              10   3857.38   15871.0         1 0.9575972      neopla       255         0
#> 4              11   3892.01   15872.0         1 0.9658887      neopla       255         0
#> 5              12   3943.50   15872.6         1 0.0384615      neopla       255         0
#> ...           ...       ...       ...       ...       ...         ...       ...       ...
#> 67077       88901   86252.5   8284.12         3  0.768924      connec         0         0
#> 67078       88902   86219.8   8291.11         2  0.993865      inflam         0       255
#> 67079       88903   86052.2   8301.45         4  0.750000      necros       255       255
#>               B   sample_id
#>       <integer> <character>
#> 1             0    sample01
#> 2             0    sample01
#> 3             0    sample01
#> 4             0    sample01
#> 5             0    sample01
#> ...         ...         ...
#> 67077       255    sample01
#> 67078         0    sample01
#> 67079         0    sample01
#>  [ reached 'max' / getOption("max.print") -- omitted 2 rows ]
```

# Importing ProvGigaPath embeddings

## Slide-level embeddings

ProvGigaPath embeddings summarize tile or slide-level image features. In
this example, we import slide-level embeddings for a single file. Each
row corresponds to a slide, with an embedding vector describing the
image-derived features.

``` r
getCatalog("provgigapath") |>
    dplyr::filter(
        filename == paste(
            "TCGA-VG-A8LO-01A-01-DX1",
            "B39A4D64-82A1-4A04-8AB6-918F3058B83B",
            "csv",
            "gz",
            sep = "."
        ) &
        level == "slide_level"
    ) |>
    getFileURLs() |>
    ProvGiga() |>
    import()
#> # A tibble: 1 × 771
#>   slideName tumorType fileName     V1    V2     V3     V4     V5    V6    V7    V8     V9    V10
#>   <chr>     <chr>     <chr>     <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>
#> 1 TCGA-VG-… <NA>      TCGA-VG… -0.355 0.584 -0.402 -0.527 0.0351 0.205 -1.14 -1.84 -0.203 -0.529
#> # ℹ 758 more variables: V11 <dbl>, V12 <dbl>, V13 <dbl>, V14 <dbl>, V15 <dbl>, V16 <dbl>,
#> #   V17 <dbl>, V18 <dbl>, V19 <dbl>, V20 <dbl>, V21 <dbl>, V22 <dbl>, V23 <dbl>, V24 <dbl>,
#> #   V25 <dbl>, V26 <dbl>, V27 <dbl>, V28 <dbl>, V29 <dbl>, V30 <dbl>, V31 <dbl>, V32 <dbl>,
#> #   V33 <dbl>, V34 <dbl>, V35 <dbl>, V36 <dbl>, V37 <dbl>, V38 <dbl>, V39 <dbl>, V40 <dbl>,
#> #   V41 <dbl>, V42 <dbl>, V43 <dbl>, V44 <dbl>, V45 <dbl>, V46 <dbl>, V47 <dbl>, V48 <dbl>,
#> #   V49 <dbl>, V50 <dbl>, V51 <dbl>, V52 <dbl>, V53 <dbl>, V54 <dbl>, V55 <dbl>, V56 <dbl>,
#> #   V57 <dbl>, V58 <dbl>, V59 <dbl>, V60 <dbl>, V61 <dbl>, V62 <dbl>, V63 <dbl>, V64 <dbl>, …
```

## Tile-level embeddings

ProvGigaPath tile-level embeddings provide a more granular
representation of image features at the tile level. Each row corresponds
to a tile, with spatial coordinates (`tile_x`, `tile_y`) and an
embedding vector describing the image-derived features for that tile. In
this example, we filter the catalog to the tile-level file corresponding
to the same slide as above.

``` r
getCatalog("provgigapath") |>
    dplyr::filter(
        filename == paste(
            "TCGA-VG-A8LO-01A-01-DX1",
            "B39A4D64-82A1-4A04-8AB6-918F3058B83B",
            "csv",
            "gz",
            sep = "."
        ) &
        level == "tile_level"
    ) |>
    getFileURLs() |>
    ProvGiga() |>
    import()
#> # A tibble: 211 × 1,543
#>    slide_name     tile_id tile_name tile_x tile_y      `0`    `1`     `2`     `3`    `4`     `5`
#>    <chr>            <dbl> <chr>      <dbl>  <dbl>    <dbl>  <dbl>   <dbl>   <dbl>  <dbl>   <dbl>
#>  1 TCGA-VG-A8LO-…       0 02155x_1…   2155  18612  0.177   -1.42   0.787   0.0380  0.753  0.0848
#>  2 TCGA-VG-A8LO-…       1 03180x_1…   3180  15540  0.433   -1.33   1.11   -0.382   0.958  0.681 
#>  3 TCGA-VG-A8LO-…       2 03180x_1…   3180  16564  0.886   -1.71  -0.0505  0.317   0.568 -0.200 
#>  4 TCGA-VG-A8LO-…       3 03180x_1…   3180  17588  0.183   -1.31  -0.599  -0.138   0.534  0.304 
#>  5 TCGA-VG-A8LO-…       4 03180x_1…   3180  18612  0.631   -0.588  0.652   0.548   0.529  0.911 
#>  6 TCGA-VG-A8LO-…       5 03180x_1…   3180  19636  0.700   -1.51   0.909   0.380   0.971  0.388 
#>  7 TCGA-VG-A8LO-…       6 04204x_1…   4204  14516  0.821   -2.47   1.05   -0.411  -0.216 -0.134 
#>  8 TCGA-VG-A8LO-…       7 04204x_1…   4204  15540  0.251   -0.958  0.259  -0.186   0.567  0.806 
#>  9 TCGA-VG-A8LO-…       8 04204x_1…   4204  16564 -0.0607  -0.917 -0.168   0.727   0.292  0.886 
#> 10 TCGA-VG-A8LO-…       9 04204x_1…   4204  17588 -0.00672 -1.05   0.460   0.600  -0.246  0.798 
#> # ℹ 201 more rows
#> # ℹ 1,532 more variables: `6` <dbl>, `7` <dbl>, `8` <dbl>, `9` <dbl>, `10` <dbl>, `11` <dbl>,
#> #   `12` <dbl>, `13` <dbl>, `14` <dbl>, `15` <dbl>, `16` <dbl>, `17` <dbl>, `18` <dbl>,
#> #   `19` <dbl>, `20` <dbl>, `21` <dbl>, `22` <dbl>, `23` <dbl>, `24` <dbl>, `25` <dbl>,
#> #   `26` <dbl>, `27` <dbl>, `28` <dbl>, `29` <dbl>, `30` <dbl>, `31` <dbl>, `32` <dbl>,
#> #   `33` <dbl>, `34` <dbl>, `35` <dbl>, `36` <dbl>, `37` <dbl>, `38` <dbl>, `39` <dbl>,
#> #   `40` <dbl>, `41` <dbl>, `42` <dbl>, `43` <dbl>, `44` <dbl>, `45` <dbl>, `46` <dbl>, …
```

# Importing multiple ProvGigaPath files

One can also import multiple files at once. Here we filter the catalog
to the first three slide-level files for the TCGA-GBM project, and
import them as a `ProvGigaList`. Each element of the list corresponds to
a slide, with the same structure as described above for slide-level
embeddings. Note that the `ProvGigaList` constructor can also accept a
vector of file paths or URLs. The `import` method for `ProvGigaList`
will then import each file in the list and return either a single
`SummarizedExperiment` or a list of `SummarizedExperiment` objects based
on the diversity of the data levels in the input files. In this example,
the catalog is filtered to a slide-level subset, so the output is a
single `SummarizedExperiment` object with three columns corresponding to
the three slides.

``` r
pgl <- getCatalog("provgigapath") |>
    dplyr::filter(level == "slide_level", Project.ID == "TCGA-GBM") |>
    dplyr::slice(1:3) |>
    getFileURLs() |>
    ProvGigaList() |>
    import()
pgl
#> class: SummarizedExperiment 
#> dim: 768 3 
#> metadata(5): slideName tumorType fileName patientIds sampleIds
#> assays(1): embeddings
#> rownames: NULL
#> rowData names(0):
#> colnames(3): TCGA-02-0001-01Z-00-DX1 TCGA-02-0001-01Z-00-DX2 TCGA-02-0001-01Z-00-DX3
#> colData names(0):
```

## Mixed level imports

The `ProvGigaList` constructor can also accept a mix of slide- and
tile-level files. In this case, the `import` method will return a list
of `SummarizedExperiment` objects, one for each data level. Here we
filter the catalog to include both slide- and tile-level files for the
same slide, and import them together.

``` r
pgl_mixed <- getCatalog("provgigapath") |>
    dplyr::filter(
        filename %in% c(
            paste(
                "TCGA-VG-A8LO-01A-01-DX1",
                "B39A4D64-82A1-4A04-8AB6-918F3058B83B",
                "csv",
                "gz",
                sep = "."
            )
        ) &
        level %in% c("slide_level", "tile_level")
    ) |>
    getFileURLs() |>
    ProvGigaList() |>
    import()
#> Warning in .as(from): NAs introduced by coercion
pgl_mixed
#> $slide_level
#> class: SummarizedExperiment 
#> dim: 768 1 
#> metadata(5): slideName tumorType fileName patientIds sampleIds
#> assays(1): embeddings
#> rownames: NULL
#> rowData names(0):
#> colnames(1): TCGA-VG-A8LO-01A-01-DX1
#> colData names(0):
#> 
#> $tile_level
#> class: SummarizedExperiment 
#> dim: 1538 1 
#> metadata(3): metadata sampleIds patientIds
#> assays(1): tiles
#> rownames: NULL
#> rowData names(0):
#> colnames(1): TCGA-VG-A8LO-01A-01-DX1
#> colData names(0):
```

# See also

You can explore the full documentation through the MOFA and Point
Pattern Analysis vignettes in the `imageTCGA` manuscript
[repository](https://github.com/billila/manuscript_imageTCGA/).

Note. More vignettes will be added as new feature types and workflows
become available.

# Shiny App: *imageTCGA*

The [imageTCGA](https://github.com/billila/imageTCGA) Shiny application
provides an interactive interface for exploring TCGA Diagnostic Image
Database metadata.

Click here to explore the shiny app:
[imageTCGA](https://shiny.sph.cuny.edu/app/imageTCGA/)

# Session Info

<details>

<summary>

Click here for Session Info
</summary>

``` r
sessionInfo()
#> R Under development (unstable) (2025-10-28 r88973)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#> 
#> Matrix products: default
#> BLAS/LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8       
#>  [4] LC_COLLATE=en_US.UTF-8     LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                  LC_ADDRESS=C              
#> [10] LC_TELEPHONE=C             LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> time zone: America/New_York
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats4    stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#>  [1] SummarizedExperiment_1.41.0 Biobase_2.71.0              GenomicRanges_1.63.1       
#>  [4] Seqinfo_1.1.0               IRanges_2.45.0              S4Vectors_0.49.0           
#>  [7] BiocGenerics_0.57.0         generics_0.1.4              MatrixGenerics_1.23.0      
#> [10] matrixStats_1.5.0           imageFeatureTCGA_0.99.56    dplyr_1.1.4                
#> [13] ImageFeatureTCGA_0.99.38    colorout_1.3-2             
#> 
#> loaded via a namespace (and not attached):
#>   [1] bitops_1.0-9                DBI_1.2.3                   httr2_1.2.2                
#>   [4] rlang_1.1.6                 magrittr_2.0.4              otel_0.2.0                 
#>   [7] compiler_4.6.0              RSQLite_2.4.5               GenomicFeatures_1.63.1     
#>  [10] png_0.1-8                   vctrs_0.6.5                 stringr_1.6.0              
#>  [13] rvest_1.0.5                 pkgconfig_2.0.3             SpatialExperiment_1.21.0   
#>  [16] crayon_1.5.3                fastmap_1.2.0               dbplyr_2.5.1               
#>  [19] magick_2.9.0                XVector_0.51.0              utf8_1.2.6                 
#>  [22] Rsamtools_2.27.0            promises_1.5.0              rmarkdown_2.30             
#>  [25] tzdb_0.5.0                  UCSC.utils_1.7.1            ps_1.9.1                   
#>  [28] purrr_1.2.0                 bit_4.6.0                   MultiAssayExperiment_1.37.2
#>  [31] xfun_0.56                   cachem_1.1.0                cigarillo_1.1.0            
#>  [34] GenomeInfoDb_1.47.2         jsonlite_2.0.0              blob_1.2.4                 
#>  [37] later_1.4.4                 DelayedArray_0.37.0         BiocParallel_1.45.0        
#>  [40] parallel_4.6.0              R6_2.6.1                    stringi_1.8.7              
#>  [43] RColorBrewer_1.1-3          rtracklayer_1.71.3          Rcpp_1.1.1                 
#>  [46] knitr_1.51                  readr_2.1.6                 BiocBaseUtils_1.13.0       
#>  [49] Matrix_1.7-4                tidyselect_1.2.1            rstudioapi_0.18.0          
#>  [52] dichromat_2.0-0.1           abind_1.4-8                 yaml_2.3.12                
#>  [55] codetools_0.2-20            websocket_1.4.4             curl_7.0.0                 
#>  [58] processx_3.8.6              rjsoncons_1.3.2             lattice_0.22-7             
#>  [61] tibble_3.3.0                BumpyMatrix_1.19.0          KEGGREST_1.51.1            
#>  [64] withr_3.0.2                 S7_0.2.1                    evaluate_1.0.5             
#>  [67] archive_1.1.12.1            BiocFileCache_3.1.0         xml2_1.5.1                 
#>  [70] Biostrings_2.79.4           pillar_1.11.1               filelock_1.0.3             
#>  [73] rsconnect_1.7.0             TCGAutils_1.31.4            RCurl_1.98-1.17            
#>  [76] vroom_1.6.6                 chromote_0.5.1              hms_1.1.4                  
#>  [79] ggplot2_4.0.1               scales_1.4.0                glue_1.8.0                 
#>  [82] tools_4.6.0                 BiocIO_1.21.0               data.table_1.18.2.1        
#>  [85] GenomicAlignments_1.47.0    XML_3.99-0.20               cowplot_1.2.0              
#>  [88] grid_4.6.0                  AnnotationDbi_1.73.0        SingleCellExperiment_1.33.0
#>  [91] restfulr_0.0.16             TENxIO_1.13.3               cli_3.6.5                  
#>  [94] rappdirs_0.3.4              GenomicDataCommons_1.35.1   S4Arrays_1.11.1            
#>  [97] gtable_0.3.6                digest_0.6.39               SparseArray_1.11.10        
#> [100] rjson_0.2.23               
#>  [ reached 'max' / getOption("max.print") -- omitted 6 entries ]
```

</details>
