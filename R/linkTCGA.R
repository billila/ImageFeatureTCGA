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
#' coad_sub <- coad[, 1:3, ]
#' catalog <- getCatalog(pipeline = "provgigapath", format = "csv")
#' linked_mae <- linkTCGA(coad_sub, catalog)
#' @export
linkTCGA <- function(
    MultiAssayExperiment, catalog, redownload = FALSE, parallel = TRUE
) {
    tcgabcodes <- TCGAutils::TCGAbarcode(catalog[["tcga_barcode"]])
    catalog <-
        catalog[tcgabcodes %in% rownames(colData(MultiAssayExperiment)), ]
    catalog[["url"]] <- getFileURLs(catalog)
    resdata <- ProvGigaList(
        catalog[["url"]],
        is_url = TRUE,
        levels = catalog[["level"]],
        parallel = parallel
    ) |>
        import(redownload = redownload, parallel = parallel)
    slide_assay <- slide_df_to_se(resdata[["slide_level"]])
    sampmap <- DataFrame(
        assay = "slide_assay",
        primary = metadata(slide_assay)[["patientIds"]],
        colname = metadata(slide_assay)[["sampleIds"]]
    )
}

slide_df_to_se <- function(tdf) {
    sampleIds <- vapply(
        strsplit(tdf[["slideName"]], "\\."),
        `[[`,
        character(1L),
        1L
    )
    patientIds <- TCGAutils::TCGAbarcode(sampleIds)
    metadata <- c(
        as.list(tdf[, c("slideName", "tumorType", "fileName")]),
        patientIds = patientIds,
        sampleIds = sampleIds
    )
    embeddings <-
        tdf[-which(names(tdf) %in% c("slideName", "tumorType", "fileName"))] |>
        as.matrix() |>
        t()
    dimnames(embeddings) <- list(
        NULL,
        sampleIds
    )
    se <- SummarizedExperiment(
        assays = list(embeddings = embeddings)
    )
    metadata(se) <- metadata
    se
}
