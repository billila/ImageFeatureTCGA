.PROV_ORDER <- c("pipeline", "level", "filename")
.HOV_ORDER <- c("pipeline", "format", "filename")

#' Link MultiAssayExperiment object to TCGA data
#'
#' @param MultiAssayExperiment A `MultiAssayExperiment` object containing sample
#'   metadata with TCGA barcodes.
#'
#' @examplesIf interactive()
#' library(curatedTCGAData)
#' coad <- curatedTCGAData(
#'     diseaseCode = "COAD",
#'     assays = "RNASeq2GeneNorm",
#'     version = "2.1.1",
#'     dry.run = FALSE
#' )
#' catalog <- getCatalog(pipeline = "provgigapath", format = "csv")
#' linked_mae <- linkTCGA(coad, catalog)
#' @export
linkTCGA <- function(
    MultiAssayExperiment, catalog, redownload = FALSE, parallel = TRUE
) {
    tcgabcodes <- TCGAutils::TCGAbarcode(catalog[["tcga_barcode"]])
    catalog <-
        catalog[tcgabcodes %in% rownames(colData(MultiAssayExperiment)), ]
    catalog[["url"]] <- getFileURLs(catalog)
    ProvGigaList(
        catalog[["url"]],
        is_url = TRUE,
        levels = catalog[["level"]],
        parallel = parallel
    ) |>
        import(redownload = redownload, parallel = parallel)
}
