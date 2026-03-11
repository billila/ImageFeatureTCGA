#' Create an embedding stack from a ProvGigaList object
#'
#' This function imports and combines embeddings from multiple ProvGigaPath
#' files contained within a ProvGigaList object. It supports both slide-level
#' and tile-level embeddings.
#'
#' @returns A named list of tibbles, where each list element corresponds to a
#'   specific level (e.g., "slide_level", "tile_level") and contains the
#'   combined embeddings from all files at that level.
#'
#' @param con `ProvGigaList` object containing multiple ProvGigaPath files or
#'   URLs.
#'
#' @param levels `character()` vector specifying the data level for each file in
#'   the `ProvGigaList`. If not provided, levels will be inferred from the
#'   `ProvGiga` objects within the list.
#'
#' @param layer `character()` vector specifying the embedding layer to import
#'   from each file. Default is `"last_layer_embed"` for "slide_level" and
#'   ignored for "tile_level".
#'
#' @param redownload `logical(1)` indicating whether to re-download cached
#'   files.
#'
#' @param ... Additional arguments passed to the slide and tile import
#'   functions.
#'
#' @examplesIf interactive()
#' slide_urls <- getCatalog("provgigapath") |>
#'     dplyr::filter(level == "slide_level", Project.ID == "TCGA-UVM") |>
#'     dplyr::slice(1:3) |>
#'     getFileURLs()
#'
#' ProvGigaList(slide_urls) |>
#'    embeddingStack(redownload = FALSE)
#' @export
embeddingStack <- function(
    con,
    levels,
    layer = "last_layer_embed",
    redownload = FALSE,
    ...
) {
    prov_paths <- path(con)

    if (con@are_URLs)
        prov_paths <- .cache_url_files(prov_paths, redownload)

    if (missing(levels))
        levels <- vapply(con@listData, function(x) { x@level }, character(1L))

    level <- unique(levels)

    tumorTypes <- vapply(
        con@listData, function(x) { x@tumorType }, character(1L)
    )

    if (missing(layer))
        layer <- rep(layer, length(prov_paths))

    import_list <- Map(
        function(path, type, level, layer, ...) {
            .import_level <- switch(
                level,
                slide_level = .import_slide_level,
                tile_level = .import_tile_level
            )
            .import_level(
                prov_path = path,
                tumorType = type,
                layer = layer,
                ...
            )
        },
        path = prov_paths,
        type = tumorTypes,
        level = levels,
        layer = layer,
        ...
    )
    split(import_list, levels) |>
        lapply(dplyr::bind_rows)
}
