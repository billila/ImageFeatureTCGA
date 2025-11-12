.PROV_BASE_URL <- "https://store.cancerdatasci.org"

#' @name listFiles
#'
#' @title List available HoVerNet and Prov-Giga-Path data for TCGA cancers
#'
#' @description Functions to list available HoverNet and ProvGiga data for TCGA
#'   cancers. HoverNet data is only available for TCGA-OV, while ProvGiga data
#'   is available for multiple TCGA cancer types at slide and tile levels. See
#'   the `TCGAcodesAvailable` dataset for a summary of available data. These
#'   functions return a `data.frame` with filenames and file sizes.
#'
#' @param diseaseCode `character(1L)` TCGA disease code (e.g., "TCGA_BRCA",
#'   "TCGA_LUAD"). For `listHoverNet()`, only "TCGA_OV" is supported. Note that
#'   the codes use an underscore ("_").
#'
#' @param format `character(1L)` One of "h5ad", "json", or "thumb" specifying
#'   the desired HoverNet data format. Default is "h5ad".
#'
#' @param level `character(1L)` One of "slide_level" or "tile_level" specifying
#'   the desired ProvGiga data level. Default is "slide_level".
#'
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


#' @rdname listFiles
#'
#' @importFrom BiocBaseUtils isScalarCharacter
#'
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
    utils::data(
        "TCGAcodesAvailable", envir = dataenv, package = "ImageFeatureTCGA"
    )
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
