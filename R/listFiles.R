.PROV_BASE_URL <- "https://store.cancerdatasci.org"

#' @examplesIf interactive()
#' ## List available HoverNet data for TCGA-OV
#' listHoverNet(format = "h5ad")
#' @export
listHoverNet <- function(
    diseaseCode = "TCGA_OV",
    format = c("h5ad", "json", "thumb")
) {
    format <- match.arg(format)
    if (!identical(diseaseCode, "TCGA_OV"))
        stop("HoverNet data is only available for diseaseCode: 'TCGA_OV'")
    hovernet_url <-
        paste(.PROV_BASE_URL, "hovernet", diseaseCode, format, "", sep = "/")
    table <- .see_more_table(hovernet_url)
    table[!grepl("^\\.\\.", table[["Filename"]]), ]
}


#' @importFrom BiocBaseUtils isScalarCharacter
#' @examplesIf interactive()
#' ## List available ProvGiga slide-level data for TCGA-BRCA
#' listProvGiga("TCGA_COAD", level = "slide_level")
#' @export
listProvGiga <- function(
    diseaseCode,
    level = c("slide_level", "tile_level")
) {
    if (missing(diseaseCode) || !isScalarCharacter(diseaseCode))
        stop("Provide a TCGA 'diseaseCode'")

    level <- match.arg(level)
    cname <- paste0(level, "_available")

    dataenv <- new.env(parent = emptyenv())
    data("TCGAcodesAvailable", envir = dataenv, package = "ImageFeatureTCGA")
    TCGAcodesAvailable <- dataenv[["TCGAcodesAvailable"]]

    prov_tumor_types <-
        TCGAcodesAvailable[TCGAcodesAvailable[[cname]], "diseaseCodes"]

    if (!(diseaseCode %in% prov_tumor_types))
        stop("No ProvGiga data available for diseaseCode: '", diseaseCode, "'")

    tumor_type_url <- paste(
        .PROV_BASE_URL, "provgigapath", level, diseaseCode, "", sep = "/"
    )
    table <- .see_more_table(tumor_type_url)
    table[!grepl("^\\.\\.", table[["Filename"]]), ]
}
