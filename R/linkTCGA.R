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
    MultiAssayExperiment, catalog
) {
    tcgabcodes <- TCGAutils::TCGAbarcode(catalog[["tcga_barcode"]])
    catalog[tcgabcodes %in% rownames(colData(MultiAssayExperiment)), ]
    ## WIP
}
