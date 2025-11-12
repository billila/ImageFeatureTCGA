#' Available ProvGigaPath and HoVerNet data for TCGA Cancers
#'
#' A `tibble` listing the TCGA disease codes for which ProvGigaPath
#' slide-level and tile-level data are available, along with logical
#' indicators for availability at each level. HoVerNet data is only
#' available for TCGA-OV.
#'
#' @format A `tibble` with the following columns:
#' \describe{
#'     \item{diseaseCodes}{TCGA disease codes (e.g., "TCGA_BRCA", "TCGA_LUAD")}
#'     \item{slide_level_available}{Logical indicator of availability of
#'       ProvGigaPath slide-level data}
#'     \item{tile_level_available}{Logical indicator of availability of
#'       ProvGigaPath tile-level data}
#'     \item{hover_available}{Logical indicator of availability of
#'       HoVerNet data}
#' }
#' @usage data("TCGAcodesAvailable", package = "ImageFeatureTCGA")
#'
#' @docType data
#'
#' @source <https://store.cancerdatasci.org/>
"TCGAcodesAvailable"
