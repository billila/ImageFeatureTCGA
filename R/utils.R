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

.import_slide_level <- function(prov_path, tumorType, ...) {
    df <- readr::read_csv(prov_path, show_col_types = FALSE)
    embedding <- df[["last_layer_embed"]][1L] |>
        gsub("tensor\\(\\[\\[|\\]\\]\\)", "", x = _) |>
        gsub("\\n", "", x = _) |>
        read.table(text = _, sep = ",")

    tibble::tibble(
        slideName = df[["slide_name"]],
        tumorType = tumorType,
        embedding
    )
}

.import_tile_level <- function(prov_path, tumorType, ...) {
    args <- list(...)
    filename <- args[["filename"]]

    df <- readr::read_csv(prov_path, show_col_types = FALSE)
    tibble::tibble(
        df,
        tumorType = tumorType,
        fileName = filename
    )
}

.extract_project <- function(file_path) {
    stopifnot(
        isScalarCharacter(file_path)
    )
    path_parts <- strsplit(file_path, "/")[[1L]]
    project <- grepv("^TCGA.[A-Z]{3,4}$", path_parts)
    if (!identical(length(project), 1L))
        stop("Cannot extract project from file path: ", file_path)
    project
}
