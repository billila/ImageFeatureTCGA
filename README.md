
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

To see which TCGA tumor types are supported:

``` r
data("TCGAcodesAvailable", package = "ImageFeatureTCGA")
TCGAcodesAvailable
#>    diseaseCodes slide_level_available tile_level_available hover_available
#> 1      TCGA_ACC                  TRUE                 TRUE           FALSE
#> 2     TCGA_BLCA                  TRUE                 TRUE           FALSE
#> 3     TCGA_CESC                  TRUE                 TRUE           FALSE
#> 4     TCGA_CHOL                  TRUE                 TRUE           FALSE
#> 5     TCGA_COAD                  TRUE                 TRUE           FALSE
#> 6     TCGA_DLBC                  TRUE                 TRUE           FALSE
#> 7     TCGA_ESCA                  TRUE                 TRUE           FALSE
#> 8      TCGA_GBM                 FALSE                 TRUE           FALSE
#> 9     TCGA_HNSC                  TRUE                 TRUE           FALSE
#> 10    TCGA_KICH                  TRUE                 TRUE           FALSE
#> 11    TCGA_KIRC                 FALSE                 TRUE           FALSE
#> 12    TCGA_KIRP                  TRUE                 TRUE           FALSE
#> 13     TCGA_LGG                 FALSE                 TRUE           FALSE
#> 14    TCGA_LIHC                  TRUE                 TRUE           FALSE
#> 15    TCGA_LUAD                 FALSE                 TRUE           FALSE
#> 16    TCGA_LUSC                  TRUE                 TRUE           FALSE
#> 17    TCGA_MESO                  TRUE                 TRUE           FALSE
#> 18      TCGA_OV                  TRUE                 TRUE            TRUE
#> 19    TCGA_PAAD                  TRUE                 TRUE           FALSE
#> 20    TCGA_PCPG                  TRUE                 TRUE           FALSE
#> 21    TCGA_PRAD                  TRUE                 TRUE           FALSE
#> 22    TCGA_READ                  TRUE                 TRUE           FALSE
#> 23    TCGA_SARC                 FALSE                 TRUE           FALSE
#> 24    TCGA_SKCM                  TRUE                 TRUE           FALSE
#> 25    TCGA_STAD                  TRUE                 TRUE           FALSE
#>  [ reached 'max' / getOption("max.print") -- omitted 6 rows ]
```

- `slide_level_available`: ProvGigaPath slide-level embeddings
- `tile_level_available`: ProvGigaPath tile-level embeddings
- `hover_available`: HoVerNet segmentation data

# Listing Available Files

### HoVerNet data

``` r
listHoverNet(diseaseCode = "TCGA_OV", format = "h5ad")
#> Total pages fetched: 1
#> # A tibble: 107 × 3
#>    Filename                                                          Modified          Size
#>    <chr>                                                             <chr>             <chr>
#>  1 TCGA-13-A5FT-01Z-00-DX1.2B292DC8-7336-4CD9-AB1A-F6F482E6151A.h5ad 2025-01-31 21:23Z 184 MB
#>  2 TCGA-13-A5FU-01Z-00-DX1.9AD9E4B9-3F87-4879-BC0F-148B12C09036.h5ad 2025-01-31 21:23Z 173 MB
#>  3 TCGA-23-1021-01Z-00-DX1.F07C221B-D401-47A5-9519-10DE59CA1E9D.h5ad 2025-01-31 21:23Z 184 MB
#>  4 TCGA-23-1022-01Z-00-DX1.AF9E523E-CB0F-4AB5-AD43-C96731BF9141.h5ad 2025-01-31 21:23Z 158 MB
#>  5 TCGA-23-1023-01Z-00-DX1.0C96E118-A4D9-4A9A-B95E-C0AA114D2483.h5ad 2025-01-31 21:23Z 196 MB
#>  6 TCGA-23-1024-01Z-00-DX1.B9194D3F-C6F4-4FC8-B0CA-6E347FF4F885.h5ad 2025-01-31 21:23Z 249 MB
#>  7 TCGA-23-1026-01Z-00-DX1.2875B4F7-D6B2-4C72-8A68-4E7C92D04BF0.h5ad 2025-01-31 21:23Z 155 MB
#>  8 TCGA-23-1027-01Z-00-DX1.53F9DFF4-6811-4184-B2FD-1F6706B948FD.h5ad 2025-01-31 21:23Z 225 MB
#>  9 TCGA-23-1028-01Z-00-DX1.117B4B7B-F796-4D33-A645-CD80E5C43E6D.h5ad 2025-01-31 21:23Z 64 MB
#> 10 TCGA-23-1029-01Z-00-DX1.0044B39A-51B3-4F76-90A9-00CDF851DE2A.h5ad 2025-01-31 21:23Z 127 MB
#> # ℹ 97 more rows
```

### ProvGigaPath data

``` r
listProvGiga("TCGA_OV", level = "slide_level")
#> Total pages fetched: 1
#> # A tibble: 107 × 3
#>    Filename                                                            Modified          Size
#>    <chr>                                                               <chr>             <chr>
#>  1 TCGA-13-A5FT-01Z-00-DX1.2B292DC8-7336-4CD9-AB1A-F6F482E6151A.csv.gz 2025-10-20 21:13Z 41 KB
#>  2 TCGA-13-A5FU-01Z-00-DX1.9AD9E4B9-3F87-4879-BC0F-148B12C09036.csv.gz 2025-10-20 21:13Z 41 KB
#>  3 TCGA-23-1021-01Z-00-DX1.F07C221B-D401-47A5-9519-10DE59CA1E9D.csv.gz 2025-10-20 21:13Z 41 KB
#>  4 TCGA-23-1022-01Z-00-DX1.AF9E523E-CB0F-4AB5-AD43-C96731BF9141.csv.gz 2025-10-20 21:13Z 41 KB
#>  5 TCGA-23-1023-01Z-00-DX1.0C96E118-A4D9-4A9A-B95E-C0AA114D2483.csv.gz 2025-10-20 21:13Z 41 KB
#>  6 TCGA-23-1024-01Z-00-DX1.B9194D3F-C6F4-4FC8-B0CA-6E347FF4F885.csv.gz 2025-10-20 21:13Z 41 KB
#>  7 TCGA-23-1026-01Z-00-DX1.2875B4F7-D6B2-4C72-8A68-4E7C92D04BF0.csv.gz 2025-10-20 21:13Z 41 KB
#>  8 TCGA-23-1027-01Z-00-DX1.53F9DFF4-6811-4184-B2FD-1F6706B948FD.csv.gz 2025-10-20 21:13Z 41 KB
#>  9 TCGA-23-1028-01Z-00-DX1.117B4B7B-F796-4D33-A645-CD80E5C43E6D.csv.gz 2025-10-20 21:13Z 41 KB
#> 10 TCGA-23-1029-01Z-00-DX1.0044B39A-51B3-4F76-90A9-00CDF851DE2A.csv.gz 2025-10-20 21:13Z 41 KB
#> # ℹ 97 more rows
```

# Importing HoVerNet data

You can import HoVerNet segmentation results as a `SpatialExperiment` or
`SpatialFeatureExperiment`.

``` r
hov_file <- paste0(
    "https://store.cancerdatasci.org/hovernet/TCGA_OV/json/",
    "TCGA-VG-A8LO-01A-01-DX1.B39A4D64-82A1-4A04-8AB6-918F3058B83B.json.gz"
)

HoverNet(hov_file, outClass = "SpatialExperiment") |>
    import()
#> Warning in rep(as.integer(len), length = length(str)): partial argument match of 'length' to 'length.out'
#> Warning in rep(as.integer(len), length = length(str)): partial argument match of 'length' to 'length.out'
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

ProvGigaPath embeddings summarize tile or slide-level image features.

``` r
prov_url <- paste0(
    "https://store.cancerdatasci.org/provgigapath/slide_level/TCGA_OV/",
    "TCGA-VG-A8LO-01A-01-DX1.B39A4D64-82A1-4A04-8AB6-918F3058B83B.csv.gz"
)

ProvGiga(prov_url) |>
    import()
#> Warning in rep(as.integer(len), length = length(str)): partial argument match of 'length' to 'length.out'
#> Warning in rep(as.integer(len), length = length(str)): partial argument match of 'length' to 'length.out'
#> # A tibble: 1 × 770
#>   slideName tumorType     V1    V2     V3     V4     V5    V6    V7    V8     V9    V10   V11   V12    V13    V14   V15   V16    V17    V18
#>   <chr>     <chr>      <dbl> <dbl>  <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl>
#> 1 TCGA-VG-… TCGA_OV   -0.352 0.594 -0.403 -0.529 0.0304 0.206 -1.13 -1.83 -0.195 -0.523 -1.03 0.519 -0.176 0.0822 -1.37 0.572 -0.975 -0.178
#> # ℹ 750 more variables: V19 <dbl>, V20 <dbl>, V21 <dbl>, V22 <dbl>, V23 <dbl>, V24 <dbl>, V25 <dbl>, V26 <dbl>, V27 <dbl>, V28 <dbl>,
#> #   V29 <dbl>, V30 <dbl>, V31 <dbl>, V32 <dbl>, V33 <dbl>, V34 <dbl>, V35 <dbl>, V36 <dbl>, V37 <dbl>, V38 <dbl>, V39 <dbl>, V40 <dbl>,
#> #   V41 <dbl>, V42 <dbl>, V43 <dbl>, V44 <dbl>, V45 <dbl>, V46 <dbl>, V47 <dbl>, V48 <dbl>, V49 <dbl>, V50 <dbl>, V51 <dbl>, V52 <dbl>,
#> #   V53 <dbl>, V54 <dbl>, V55 <dbl>, V56 <dbl>, V57 <dbl>, V58 <dbl>, V59 <dbl>, V60 <dbl>, V61 <dbl>, V62 <dbl>, V63 <dbl>, V64 <dbl>,
#> #   V65 <dbl>, V66 <dbl>, V67 <dbl>, V68 <dbl>, V69 <dbl>, V70 <dbl>, V71 <dbl>, V72 <dbl>, V73 <dbl>, V74 <dbl>, V75 <dbl>, V76 <dbl>,
#> #   V77 <dbl>, V78 <dbl>, V79 <dbl>, V80 <dbl>, V81 <dbl>, V82 <dbl>, V83 <dbl>, V84 <dbl>, V85 <dbl>, V86 <dbl>, V87 <dbl>, V88 <dbl>,
#> #   V89 <dbl>, V90 <dbl>, V91 <dbl>, V92 <dbl>, V93 <dbl>, V94 <dbl>, V95 <dbl>, V96 <dbl>, V97 <dbl>, V98 <dbl>, V99 <dbl>, V100 <dbl>, …
```

Each row corresponds to a slide, with an embedding vector describing the
image-derived features.

# See also

You can explore the full documentation through the package vignettes:

- [MOFA](https://github.com/waldronlab/ImageFeatureTCGA/blob/devel/vignettes/MOFA_analysis.qmd)
- [Point Pattern
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
#> R Under development (unstable) (2025-10-28 r88973)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.3 LTS
#>
#> Matrix products: default
#> BLAS/LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#>
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C               LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8     LC_MONETARY=en_US.UTF-8
#>  [6] LC_MESSAGES=en_US.UTF-8    LC_PAPER=en_US.UTF-8       LC_NAME=C                  LC_ADDRESS=C               LC_TELEPHONE=C
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C
#>
#> time zone: America/New_York
#> tzcode source: system (glibc)
#>
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base
#>
#> other attached packages:
#> [1] dplyr_1.1.4             ImageFeatureTCGA_0.99.7 colorout_1.3-2
#>
#> loaded via a namespace (and not attached):
#>  [1] tidyselect_1.2.1            blob_1.2.4                  filelock_1.0.3              bitops_1.0-9
#>  [5] fastmap_1.2.0               SingleCellExperiment_1.33.0 RCurl_1.98-1.17             BiocFileCache_3.1.0
#>  [9] promises_1.5.0              digest_0.6.38               lifecycle_1.0.4             processx_3.8.6
#> [13] RSQLite_2.4.4               magrittr_2.0.4              compiler_4.6.0              rlang_1.1.6
#> [17] tools_4.6.0                 utf8_1.2.6                  yaml_2.3.10                 knitr_1.50
#> [21] S4Arrays_1.11.0             bit_4.6.0                   curl_7.0.0                  DelayedArray_0.37.0
#> [25] xml2_1.5.0                  abind_1.4-8                 rsconnect_1.6.1             websocket_1.4.4
#> [29] withr_3.0.2                 purrr_1.2.0                 BiocGenerics_0.57.0         grid_4.6.0
#> [33] stats4_4.6.0                SummarizedExperiment_1.41.0 cli_3.6.5                   rmarkdown_2.30
#> [37] crayon_1.5.3                generics_0.1.4              otel_0.2.0                  rstudioapi_0.17.1
#> [41] httr_1.4.7                  tzdb_0.5.0                  rjson_0.2.23                BiocBaseUtils_1.13.0
#> [45] DBI_1.2.3                   cachem_1.1.0                chromote_0.5.1              stringr_1.6.0
#> [49] rvest_1.0.5                 parallel_4.6.0              selectr_0.4-2               XVector_0.51.0
#> [53] matrixStats_1.5.0           vctrs_0.6.5                 Matrix_1.7-4                jsonlite_2.0.0
#> [57] IRanges_2.45.0              hms_1.1.4                   S4Vectors_0.49.0            bit64_4.6.0-1
#> [61] archive_1.1.12              TENxIO_1.13.0               magick_2.9.0                glue_1.8.0
#> [65] codetools_0.2-20            ps_1.9.1                    stringi_1.8.7               later_1.4.4
#> [69] BiocIO_1.21.0               GenomicRanges_1.63.0        tibble_3.3.0                pillar_1.11.1
#> [73] rappdirs_0.3.3              htmltools_0.5.8.1           Seqinfo_1.1.0               R6_2.6.1
#> [77] dbplyr_2.5.1                httr2_1.2.1                 vroom_1.6.6                 evaluate_1.0.5
#> [81] lattice_0.22-7              Biobase_2.71.0              readr_2.1.6                 SpatialExperiment_1.21.0
#> [85] memoise_2.0.1               rjsoncons_1.3.2             Rcpp_1.1.0                  SparseArray_1.11.2
#> [89] xfun_0.54                   MatrixGenerics_1.23.0       pkgconfig_2.0.3
```

</details>
