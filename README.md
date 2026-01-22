
# ImageFeatureTCGA

``` r
library(ImageFeatureTCGA)
library(dplyr)
```

# Overview

`ImageFeatureTCGA` (`imageTCGA`) provides convenient access to
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

BiocManager::install("waldronlab/ImageFeatureTCGA")
```

# Available Data

Use the following function to download the catalog of available files:

``` r
getCatalog()
#> # A tibble: 54,253 × 25
#>    pipeline format  filename    fullpath fnsansext tcga_barcode Case.ID TSS.Code
#>    <chr>    <chr>   <chr>       <chr>    <chr>     <chr>        <chr>   <chr>   
#>  1 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  2 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  3 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  4 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  5 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  6 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  7 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  8 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  9 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#> 10 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#> # ℹ 54,243 more rows
#> # ℹ 17 more variables: File.ID <chr>, File.Name <chr>, Data.Category <chr>,
#> #   Data.Type <chr>, Project.ID <chr>, Sample.ID <chr>, Sample.Type <chr>,
#> #   Source.Site <chr>, Study.Name <chr>, BCR <chr>, city <chr>, state <chr>,
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
#>    pipeline format  filename    fullpath fnsansext tcga_barcode Case.ID TSS.Code
#>    <chr>    <chr>   <chr>       <chr>    <chr>     <chr>        <chr>   <chr>   
#>  1 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  2 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  3 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  4 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  5 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  6 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  7 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  8 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  9 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#> 10 hovernet geojson TCGA-02-00… hoverne… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#> # ℹ 33,167 more rows
#> # ℹ 17 more variables: File.ID <chr>, File.Name <chr>, Data.Category <chr>,
#> #   Data.Type <chr>, Project.ID <chr>, Sample.ID <chr>, Sample.Type <chr>,
#> #   Source.Site <chr>, Study.Name <chr>, BCR <chr>, city <chr>, state <chr>,
#> #   country <chr>, bcr_patient_uuid <chr>, lat <dbl>, lon <dbl>, level <chr>
```

### ProvGigaPath data

``` r
getCatalog("provgigapath")
#> # A tibble: 21,076 × 25
#>    pipeline     format filename fullpath fnsansext tcga_barcode Case.ID TSS.Code
#>    <chr>        <chr>  <chr>    <chr>    <chr>     <chr>        <chr>   <chr>   
#>  1 provgigapath csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  2 provgigapath csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  3 provgigapath csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  4 provgigapath csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  5 provgigapath csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  6 provgigapath csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  7 provgigapath csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  8 provgigapath csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#>  9 provgigapath csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#> 10 provgigapath csv    TCGA-02… provgig… TCGA-02-… TCGA-02-000… TCGA-0… 02      
#> # ℹ 21,066 more rows
#> # ℹ 17 more variables: File.ID <chr>, File.Name <chr>, Data.Category <chr>,
#> #   Data.Type <chr>, Project.ID <chr>, Sample.ID <chr>, Sample.Type <chr>,
#> #   Source.Site <chr>, Study.Name <chr>, BCR <chr>, city <chr>, state <chr>,
#> #   country <chr>, bcr_patient_uuid <chr>, lat <dbl>, lon <dbl>, level <chr>
```

# Importing HoVerNet data

You can import HoVerNet segmentation results as a `SpatialExperiment` or
`SpatialFeatureExperiment`.

``` r
getCatalog("hovernet") |>
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

# Importing ProvGigaPath embeddings

80

ProvGigaPath embeddings summarize tile or slide-level image features.

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
#>   slideName     tumorType fileName     V1    V2     V3     V4     V5    V6    V7
#>   <chr>         <chr>     <chr>     <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl>
#> 1 TCGA-VG-A8LO… <NA>      TCGA-VG… -0.355 0.584 -0.402 -0.527 0.0351 0.205 -1.14
#> # ℹ 761 more variables: V8 <dbl>, V9 <dbl>, V10 <dbl>, V11 <dbl>, V12 <dbl>,
#> #   V13 <dbl>, V14 <dbl>, V15 <dbl>, V16 <dbl>, V17 <dbl>, V18 <dbl>,
#> #   V19 <dbl>, V20 <dbl>, V21 <dbl>, V22 <dbl>, V23 <dbl>, V24 <dbl>,
#> #   V25 <dbl>, V26 <dbl>, V27 <dbl>, V28 <dbl>, V29 <dbl>, V30 <dbl>,
#> #   V31 <dbl>, V32 <dbl>, V33 <dbl>, V34 <dbl>, V35 <dbl>, V36 <dbl>,
#> #   V37 <dbl>, V38 <dbl>, V39 <dbl>, V40 <dbl>, V41 <dbl>, V42 <dbl>,
#> #   V43 <dbl>, V44 <dbl>, V45 <dbl>, V46 <dbl>, V47 <dbl>, V48 <dbl>, …
```

Each row corresponds to a slide, with an embedding vector describing the
image-derived features.

# See also

You can explore the full documentation through the package vignettes:

\-[MOFA](https://github.com/waldronlab/ImageFeatureTCGA/blob/devel/vignettes/MOFA_analysis.qmd)
-[Point Pattern
Analysis](https://github.com/waldronlab/ImageFeatureTCGA/blob/devel/vignettes/PPA.Rmd)

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
#> R version 4.5.2 (2025-10-31)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.3 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.12.0 
#> LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.12.0  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
#>  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
#>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> time zone: Europe/Rome
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] dplyr_1.1.4              ImageFeatureTCGA_0.99.21
#> 
#> loaded via a namespace (and not attached):
#>  [1] tidyselect_1.2.1            farver_2.1.2               
#>  [3] blob_1.3.0                  bitops_1.0-9               
#>  [5] filelock_1.0.3              S7_0.2.1                   
#>  [7] RCurl_1.98-1.17             fastmap_1.2.0              
#>  [9] SingleCellExperiment_1.32.0 BiocFileCache_3.0.0        
#> [11] digest_0.6.39               lifecycle_1.0.5            
#> [13] RSQLite_2.4.5               magrittr_2.0.4             
#> [15] compiler_4.5.2              rlang_1.1.7                
#> [17] tools_4.5.2                 utf8_1.2.6                 
#> [19] yaml_2.3.12                 knitr_1.51                 
#> [21] S4Arrays_1.10.1             bit_4.6.0                  
#> [23] curl_7.0.0                  DelayedArray_0.36.0        
#> [25] xml2_1.5.2                  RColorBrewer_1.1-3         
#> [27] abind_1.4-8                 withr_3.0.2                
#> [29] purrr_1.2.1                 BiocGenerics_0.56.0        
#> [31] grid_4.5.2                  stats4_4.5.2               
#> [33] ggplot2_4.0.1               scales_1.4.0               
#> [35] dichromat_2.0-0.1           SummarizedExperiment_1.40.0
#> [37] cli_3.6.5                   rmarkdown_2.30             
#> [39] crayon_1.5.3                generics_0.1.4             
#> [41] otel_0.2.0                  rstudioapi_0.18.0          
#> [43] httr_1.4.7                  tzdb_0.5.0                 
#> [45] rjson_0.2.23                BiocBaseUtils_1.12.0       
#> [47] DBI_1.2.3                   cachem_1.1.0               
#> [49] rvest_1.0.5                 parallel_4.5.2             
#> [51] XVector_0.50.0              matrixStats_1.5.0          
#> [53] vctrs_0.7.0                 Matrix_1.7-4               
#> [55] jsonlite_2.0.0              IRanges_2.44.0             
#> [57] hms_1.1.4                   S4Vectors_0.48.0           
#> [59] bit64_4.6.0-1               archive_1.1.12.1           
#> [61] TENxIO_1.12.1               magick_2.9.0               
#> [63] glue_1.8.0                  codetools_0.2-20           
#> [65] cowplot_1.2.0               gtable_0.3.6               
#> [67] BiocIO_1.20.0               GenomicRanges_1.62.1       
#> [69] tibble_3.3.1                pillar_1.11.1              
#> [71] rappdirs_0.3.4              htmltools_0.5.9            
#> [73] Seqinfo_1.0.0               R6_2.6.1                   
#> [75] dbplyr_2.5.1                httr2_1.2.2                
#> [77] vroom_1.6.7                 evaluate_1.0.5             
#> [79] lattice_0.22-7              Biobase_2.70.0             
#> [81] readr_2.1.5                 SpatialExperiment_1.20.0   
#> [83] memoise_2.0.1               rjsoncons_1.3.2            
#> [85] Rcpp_1.1.1                  SparseArray_1.10.8         
#> [87] xfun_0.56                   MatrixGenerics_1.22.0      
#> [89] pkgconfig_2.0.3
```

</details>
