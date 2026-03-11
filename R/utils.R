#' @importFrom BiocBaseUtils isScalarCharacter
.is_url <- function(url) {
    stopifnot(
        isScalarCharacter(url)
    )
    grepl("^https?://|^ftp://", url)
}

.SENTINEL_MULTI_DOWNLOAD_FRAME <- data.frame(
    success = logical(),
    status_code = integer(),
    resumefrom = numeric(),
    url = character(),
    destfile = character(),
    error = character(),
    type = character(),
    modified = character(),
    time = numeric(),
    headers = character(),
    stringsAsFactors = FALSE
)

multi_download_retry <- function(urls, destfiles, max_tries = 3L) {
    results <- .SENTINEL_MULTI_DOWNLOAD_FRAME[seq_along(urls), ]
    results[["url"]] <- urls
    results[["success"]] <- rep(FALSE, length(urls))
    results[["destfile"]] <- destfiles
    rownames(results) <- NULL

    pending_idx <- seq_along(urls)
    attempt <- 1

    while (length(pending_idx) && attempt <= max_tries) {
        res <- curl::multi_download(urls[pending_idx], destfiles[pending_idx])
        results[pending_idx, ] <- res

        succeeded <- !is.na(res[["success"]]) & res[["success"]]
        failed_mask <- !succeeded

        pending_idx <- pending_idx[failed_mask]

        if (length(pending_idx)) {
            attempt <- attempt + 1
            if (attempt <= max_tries) {
                wait <- 2^attempt
                Sys.sleep(wait)
            }
        }
    }

    if (length(pending_idx))
        warning(
            length(pending_idx),
            " file(s) failed after ",
            max_tries,
            " attempts."
        )

    results
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

.file_dirs_create <- function(files) {
    dirs <- dirname(files) |>
        unique()

    dexist <- dir.exists(dirs)
    if (!all(dexist))
        vapply(
            dirs[!dexist],
            dir.create,
            logical(1L),
            recursive = TRUE,
            showWarnings = FALSE
        )
    else
        TRUE
}

.cache_url_files <- function(urls, redownload = FALSE, parallel, bfc) {
    checkInstalled("curl")
    checkInstalled("BiocFileCache")

    if (missing(bfc)) {
        cache <- getOption(
            "BiocFileCache.cache", BiocFileCache::getBFCOption("CACHE")
        )
        bfc <- BiocFileCache::BiocFileCache(cache = cache)
    } else {
        cache <- BiocFileCache::bfccache(bfc)
    }
    queries <- .url_query(bfc, urls)
    cached <- .is_cached(queries)
    locals <- vector("list", length(urls))
    if (!redownload)
        locals[cached] <- .rpath_cache(queries[cached])
    urls <- urls[!cached | redownload]
    if (length(urls)) {
        part_urls <- gsub(paste0(.BASE_URL, "/"), "", urls)
        temppaths <- file.path(tempfile(), part_urls)
        .file_dirs_create(temppaths)
        destfiles <- file.path(cache, part_urls)
        .file_dirs_create(destfiles)

        output <- multi_download_retry(
            urls = urls,
            destfiles = temppaths
        )
        success <- output[["success"]]
        failed <- !success
        if (any(failed)) {
            warning(
                "Some downloads failed:\n  ",
                paste(urls[failed], collapse = "\n  "),
                "\n  Reasons: ",
                paste(output[failed, "error"], collapse = ";\n  ")
            )
        }
        Map(
            function(file, dest, success) {
                if (success)
                    file.rename(file, dest)
            },
            file = output[["destfile"]],
            dest = destfiles,
            success = success
        )

        locals <- mapply(
            function(bfc, url, file, cached, success) {
                if (!cached && success)
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
            url = output[["url"]],
            file = destfiles,
            cached = cached,
            success = output[["success"]],
            MoreArgs = list(bfc = bfc),
            SIMPLIFY = FALSE
        )
    }
    unlist(locals)
}

.import_slide_level <- function(
    prov_path, tumorType, layer = "last_layer_embed", ...
) {
    df <- readr::read_csv(prov_path, show_col_types = FALSE)
    embedding <- df[[layer]][1L] |>
        gsub("tensor\\(\\[\\[|\\]\\]\\)", "", x = _) |>
        gsub("\\n", "", x = _) |>
        read.table(text = _, sep = ",")

    tibble::tibble(
        slideName = df[["slide_name"]],
        tumorType = tumorType,
        fileName = basename(prov_path),
        embedding
    )
}

.import_tile_level <- function(
    prov_path, tumorType, layer, ...
) {
    df <- readr::read_csv(prov_path, show_col_types = FALSE)
    tibble::tibble(
        df,
        tumorType = tumorType,
        fileName = basename(prov_path)
    )
}
