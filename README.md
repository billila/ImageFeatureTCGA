# Introduction

`ImageFeatureTCGA` (`imageTCGA`) provides convenient access to
histopathology-derived data from **TCGA** through two complementary pipelines:

- **HoVerNet** → cell segmentation and classification
- **ProvGigaPath** → slide- and tile-level embeddings


These datasets can be imported directly into R as Bioconductor objects,
facilitating downstream integration with TCGA omics and clinical data.


## Install 

```r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("waldronlab/ImageFeatureTCGA")
```

## Vignettes

You can explore the full documentation through the package vignettes:

- [Import Image Features](https://github.com/waldronlab/ImageFeatureTCGA/blob/devel/vignettes/import_features.Rmd)   
- [MOFA](https://github.com/waldronlab/ImageFeatureTCGA/blob/devel/vignettes/MOFA_analysis.qmd)
- [Point Pattern Analysis](https://github.com/waldronlab/ImageFeatureTCGA/blob/devel/vignettes/PPA.Rmd)

> More vignettes will be added as new feature types and workflows
become available.

## Shiny App: *imageTCGA*

The [imageTCGA](https://github.com/billila/imageTCGA) Shiny application provides an interactive
interface for exploring TCGA Diagnostic Image Database metadata.

Click here to explore the shiny app: [imageTCGA](https://shiny.sph.cuny.edu/app/imageTCGA/)