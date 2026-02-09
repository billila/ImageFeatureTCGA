#' @importFrom BiocBaseUtils isScalarCharacter
.is_url <- function(url) {
    stopifnot(
        isScalarCharacter(url)
    )
    grepl("^https?://|^ftp://", url)
}

.cache_url_file <- function(url, redownload = FALSE, bfc) {
    if (missing(bfc))
        bfc <- BiocFileCache::BiocFileCache(
            cache = getOption(
                "BiocFileCache.cache", BiocFileCache::getBFCOption("CACHE")
            )
        )
    bquery <- BiocFileCache::bfcquery(bfc, url, "rname", exact = TRUE)
    cached <- identical(nrow(bquery), 1L)

    if (!redownload && cached)
        return(
            BiocFileCache::bfcrpath(
                bfc, rnames = url, exact = TRUE, download = TRUE, rtype = "web"
            )
        )

    cache <- BiocFileCache::bfccache(bfc)
    part_url <- gsub(paste0(.BASE_URL, "/"), "", url)
    destfile <- file.path(cache, part_url)
    destfolder <- dirname(destfile)
    if (!dir.exists(destfolder))
        dir.create(destfolder, recursive = TRUE, showWarnings = FALSE)
    file <- curl::curl_download(url = url, destfile = destfile)
    if (!cached)
        BiocFileCache::bfcadd(
            x = bfc,
            rname = url,
            fpath = file,
            rtype = "local",
            action = "asis",
            fname = "exact",
            exact = TRUE
        )
    else
        file
}

.url_query <- function(bfc, urls) {
    lapply(
        urls,
        function(url) {
            BiocFileCache::bfcquery(bfc, url, "rname", exact = TRUE)
        }
    )
}

.is_cached <- function(qframe) {
    vapply(qframe, nrow, integer(1L)) == 1L
}

.rpath_cache <- function(qframe) {
    vapply(qframe, `[[`, character(1L), "rpath")
}

.cache_url_files <- function(urls, redownload = FALSE, parallel = TRUE) {
    checkInstalled("curl")
    checkInstalled("BiocFileCache")
    cache <- getOption(
        "BiocFileCache.cache", BiocFileCache::getBFCOption("CACHE")
    )
    bfc <- BiocFileCache::BiocFileCache(cache = cache)
    if (parallel) {
        queries <- .url_query(bfc, urls)
        cached <- .is_cached(queries)
        locals <- vector("list", length(urls))

        if (!redownload)
            locals[cached] <- .rpath_cache(queries[cached])
        urls <- urls[!cached | redownload]
        if (length(urls)) {
            part_urls <- gsub(paste0(.BASE_URL, "/"), "", urls)
            destfiles <- file.path(cache, part_urls)
            destfolders <- dirname(destfiles) |>
                unique()
            dexist <- dir.exists(destfolders)
            if (!all(dexist))
                vapply(
                    destfolders[!dexist],
                    dir.create,
                    logical(1L),
                    recursive = TRUE,
                    showWarnings = FALSE
                )
            output <- curl::multi_download(
                urls = urls,
                destfiles = destfiles
            )
            successframe <- output[output[["success"]], , drop = FALSE]
            successurls <- urls[output[["success"]]]
            successfiles <- successframe[["destfile"]]

            locals <- BiocParallel::bpmapply(
                function(bfc, url, file, cached, bfcid) {
                    if (!cached)
                        BiocFileCache::bfcadd(
                            x = bfc,
                            rname = url,
                            fpath = file,
                            rtype = "local",
                            action = "asis",
                            fname = "exact",
                            exact = TRUE
                        )
                    else
                        file
                },
                url = successurls,
                file = successfiles,
                cached = cached,
                MoreArgs = list(bfc = bfc),
                SIMPLIFY = FALSE
            )
        }
        unlist(locals)
    } else {
        vapply(
            urls,
            function(url) {
                .cache_url_file(
                    url = url,
                    redownload = redownload,
                    bfc = bfc
                )
            },
            character(1L)
        )
    }
}

.import_slide_level <- function(
    prov_path, tumorType, fileName, layer = "last_layer_embed", ...
) {
    df <- readr::read_csv(prov_path, show_col_types = FALSE)
    embedding <- df[[layer]][1L] |>
        gsub("tensor\\(\\[\\[|\\]\\]\\)", "", x = _) |>
        gsub("\\n", "", x = _) |>
        read.table(text = _, sep = ",")

    tibble::tibble(
        slideName = df[["slide_name"]],
        tumorType = tumorType,
        fileName = fileName,
        embedding
    )
}

.import_tile_level <- function(prov_path, tumorType, fileName, ...) {
    df <- readr::read_csv(prov_path, show_col_types = FALSE)
    tibble::tibble(
        df,
        tumorType = tumorType,
        fileName = fileName
    )
}
