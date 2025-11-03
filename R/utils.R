#' @importFrom BiocBaseUtils isScalarCharacter
.is_url <- function(url) {
    stopifnot(
        isScalarCharacter(url)
    )
    grepl("^https?://|^ftp://", url)
}
