#' @importFrom BiocBaseUtils isScalarCharacter
.is_url <- function(url) {
    stopifnot(
        isScalarCharacter(url)
    )
    grepl("^https?://|^ftp://", url)
}

.cache_url_file <- function(url, redownload = FALSE) {
    checkInstalled("BiocFileCache")
    bfc <- BiocFileCache::BiocFileCache()
    bquery <- BiocFileCache::bfcquery(bfc, url, "rname", exact = TRUE)
    ## only re-download manually b/c bfcneedsupdate always returns TRUE
    if (identical(nrow(bquery), 1L) && redownload)
        BiocFileCache::bfcdownload(
            x = bfc, rid = bquery[["rid"]], ask = FALSE
        )

    BiocFileCache::bfcrpath(
        x = bfc,
        rnames = url,
        rtype = "web",
        download = TRUE,
        fname = "exact",
        exact = TRUE
    )
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
    if (parallel) {
        checkInstalled("curl")
        checkInstalled("BiocFileCache")
        bfc <- BiocFileCache::BiocFileCache()
        queries <- .url_query(bfc, urls)
        cached <- .is_cached(queries)
        locals <- vector("list", length(urls))

        if (!redownload)
            locals[cached] <- .rpath_cache(queries[cached])
        urls <- urls[!cached | redownload]
        if (length(urls)) {
            destfiles <- file.path(
                BiocFileCache::getBFCOption("CACHE"), basename(urls)
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
                    redownload = redownload
                )
            },
            character(1L)
        )
    }
}

#' @importFrom rvest html_nodes html_table html_element html_attr read_html
#' @importFrom httr2 request req_perform resp_body_string
.see_more_table <- function(u24_url, verbose = TRUE) {
    results <- list()
    current_url <- u24_url
    page_count <- 1

    while (!is.null(current_url)) {
        page_html <- request(current_url) |>
            req_perform() |>
            resp_body_string() |>
            read_html()

        table_data <- page_html |>
            html_nodes("table") |>
            html_table(fill = TRUE)

        results[[page_count]] <- table_data

        cursor_node <- page_html |>
            html_element("a:contains('see more')")

        if (!is.na(cursor_node)) {
            query_string <- html_attr(cursor_node, "href")
            current_url <- paste0(u24_url, query_string)
            page_count <- page_count + 1
        } else {
            current_url <- NULL
            if (verbose)
                message("Total pages fetched: ", page_count)
        }
    }
    dplyr::bind_rows(
        unlist(results, recursive = FALSE)
    )
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

.extract_tcgabcode <- function(file_path) {
    stopifnot(
        isScalarCharacter(file_path)
    )
    utils::head(
        strsplit(basename(file_path), "\\.")[[1L]],
        1L
    )
}
