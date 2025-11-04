#' @importFrom BiocBaseUtils isScalarCharacter
.is_url <- function(url) {
    stopifnot(
        isScalarCharacter(url)
    )
    grepl("^https?://|^ftp://", url)
}

.cache_url_file <- function(url, redownload = TRUE) {
    checkInstalled("BiocFileCache")
    bfc <- BiocFileCache::BiocFileCache()
    bquery <- BiocFileCache::bfcquery(bfc, url, "rname", exact = TRUE)
    ## only re-download manually b/c bfcneedsupdate always returns TRUE
    if (identical(nrow(bquery), 1L) && redownload)
        BiocFileCache::bfcdownload(
            x = bfc, rid = bquery[["rid"]], ask = FALSE
        )

    BiocFileCache::bfcrpath(
        bfc, rnames = url, exact = TRUE, download = TRUE, rtype = "web"
    )
}
