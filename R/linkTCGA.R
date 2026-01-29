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
#' linkTCGA(coad_sub, catalog)
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
    slide_assay <- .slide_df_to_se(resdata[["slide_level"]])
    sampmap <- DataFrame(
        assay = "slide_assay",
        primary = metadata(slide_assay)[["patientIds"]],
        colname = metadata(slide_assay)[["sampleIds"]]
    )
    c(
        MultiAssayExperiment,
        slide_assay = slide_assay,
        sampleMap = sampmap
    )
}

#' @importFrom SummarizedExperiment SummarizedExperiment
.slide_df_to_se <- function(sdf) {
    sampleIds <- .slide_to_sampleId(sdf[["slideName"]])
    patientIds <- TCGAutils::TCGAbarcode(sampleIds)
    metadata <- append(
        as.list(sdf[, c("slideName", "tumorType", "fileName")]),
        list(
            patientIds = patientIds,
            sampleIds = sampleIds
        )
    )
    embeddings <-
        sdf[-which(names(sdf) %in% c("slideName", "tumorType", "fileName"))] |>
        as.matrix() |>
        t()
    dimnames(embeddings) <- list(
        NULL,
        sampleIds
    )
    SummarizedExperiment(
        assays = list(embeddings = embeddings),
        metadata = metadata
    )
}

.slide_to_sampleId <- function(txt) {
    vapply(strsplit(txt, "\\."), `[[`, character(1L), 1L)
}
