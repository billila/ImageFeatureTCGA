#' @name ProvGigaList
#'
#' @aliases ProvGigaList-class
#'
#' @title ProvGigaList class for handling lists of ProvGiga objects
#'
#' @description The `ProvGigaList` class is a container for multiple `ProvGiga`
#'   objects, allowing for efficient management and manipulation of collections
#'   of ProvGiga data. It extends the `SimpleList` class from the `S4Vectors`
#'   package.
#'
#' @exportClass ProvGigaList
.ProvGigaList <- setClass(
    "ProvGigaList",
    contains = "SimpleList",
    slots = c(
        are_URLs = "logical"
    )
)

.validProvGigaList <- function(object) {
    validClasses <- vapply(
        object,
        function(elem) is(elem, "ProvGiga"),
        logical(1L)
    )
    if (all(validClasses))
        TRUE
    else
        "Some list elements are not of class 'ProvGiga'"
}

#' @rdname ProvGigaList
#'
#' @description The `ProvGigaList` constructor function creates an instance of
#'   the `ProvGigaList` class. It accepts multiple `ProvGiga` objects, a vector
#'   of file paths or URLs, or a list of these elements.
#'
#' @param ... Multiple `ProvGiga` objects, a vector of file paths or URLs, or a
#'   list of these elements. For `import`, futher arguments are passed to the
#'   `import` method for the individual `ProvGiga` objects.
#'
#' @param is_url `logical(1L)` whether the input resources are URLs. Default is
#'   `TRUE`.
#'
#' @param levels `character()` the data levels for each resource. Default is
#'   `"slide_level"`.
#'
#' @param parallel `logical(1L)` whether to use parallel processing. Default is
#'   `FALSE`.
#'
#' @returns * A `ProvGigaList` object containing multiple `ProvGiga` objects.
#' * `import-ProvGigaList`: Either a single `SummarizedExperiment` (if all
#'   objects are the same level) or a list of `SummarizedExperiment` objects (if
#'   levels differ).
#' * `getEmbeddings`: A matrix of embeddings extracted from all slide-level
#'   `ProvGiga` objects in the list.
#'
#' @examples
#' ## slide level imports
#' slide_urls <- getCatalog("provgigapath") |>
#'     dplyr::filter(level == "slide_level", Project.ID == "TCGA-UVM") |>
#'     dplyr::slice(1:3) |>
#'     getFileURLs()
#'
#' ## set a temporary BiocFileCache cache location
#' old <- options(BiocFileCache.cache = tempdir())
#' on.exit(options(BiocFileCache.cache = old))
#'
#' ProvGigaList(slide_urls) |>
#'    import(redownload = FALSE, parallel = FALSE)
#'
#' ## tile level imports
#' tile_urls <- getCatalog("provgigapath") |>
#'    dplyr::filter(level == "tile_level", Project.ID == "TCGA-GBM") |>
#'    dplyr::slice(1:2) |>
#'    getFileURLs()
#'
#' ProvGigaList(tile_urls) |>
#'    import(redownload = FALSE, parallel = FALSE)
#' @export
ProvGigaList <- function(
    ..., is_url = TRUE, levels = "slide_level", parallel = FALSE
) {
    dots <- S4Vectors::SimpleList(...)
    undots <- dots[[1L]]
    if (identical(length(dots), 1L)) {
        if (is.list(undots) || is(undots, "SimpleList")) {
            dots <- undots
        }
    }
    if (missing(levels) && is_url && is.character(undots))
        levels <- gsub(".*\\/(tile_level|slide_level)\\/.*", "\\1", undots)
    else if (missing(levels))
        levels <- rep(levels, lengths(dots))

    if (is.character(undots)) {
        mapplyFUN <-
            if (parallel && checkInstalled("BiocParallel"))
                BiocParallel::bpmapply
            else
                mapply
        mapplyFUN(
            ProvGiga,
            resource = undots,
            level = levels,
            MoreArgs = list(is_url = is_url),
            SIMPLIFY = FALSE
        ) |>
            unname() |>
            .ProvGigaList(are_URLs = is_url)
    } else {
        .ProvGigaList(dots, are_URLs = is_url)
    }
}

#' @rdname ProvGigaList
#'
#' @section `path`: The `path` method for `ProvGigaList` objects retrieves the
#'   file paths or URLs of all contained `ProvGiga` objects.
#'
#' @param object A `ProvGigaList` object.
#'
#' @inheritParams BiocGenerics::path
#'
#' @exportMethod path
setMethod("path", "ProvGigaList", function(object, ...) {
    vapply(object, path, character(1L))
})

#' @rdname ProvGigaList
#'
#' @section `import`: The `import` method for `ProvGigaList` objects imports the
#'   data from all contained `ProvGiga` objects and returns a list of `tibbles`.
#'
#' @inheritParams BiocIO::import
#'
#' @exportMethod import
setMethod("import", "ProvGigaList", function(con, format, text, ...) {
    prov_paths <- path(con)

    args <- list(...)
    redownload <- args[["redownload"]] %||% FALSE
    parallel <- args[["parallel"]] %||% FALSE
    args <- args[names(args) != c("redownload", "parallel")]

    if (con@are_URLs)
        prov_paths <- .cache_url_files(prov_paths, redownload, parallel)

    levels <- vapply(
        con@listData, function(x) { x@level }, character(1L)
    )
    level <- unique(levels)

    tumorTypes <- vapply(
        con@listData, function(x) { x@tumorType }, character(1L)
    )

    import_list <- Map(
        function(path, type, fn, level, ...) {
            .import_level <- switch(
                level,
                slide_level = .import_slide_level,
                tile_level = .import_tile_level
            )
            .import_level(
                prov_path = path,
                tumorType = type,
                fileName = fn,
                ...
            )
        },
        path = prov_paths,
        type = tumorTypes,
        fn = prov_paths,
        level = levels,
        ...
    )
    split_list <- split(import_list, levels) |>
        lapply(dplyr::bind_rows)
    result <- Map(
        function(data, lvl) {
            switch(
                lvl,
                slide_level = .slide_df_to_se,
                tile_level = .tile_df_to_bumpy_se
            )(data)
        },
        data = split_list,
        lvl = names(split_list)
    )
    if (identical(length(level), 1L))
        result[[level]]
    else
        result
})

#' @rdname ProvGigaList
#'
#' @inheritParams ProvGiga
#'
#' @description The `getEmbeddings` function extracts and combines the
#'   embeddings from all `ProvGiga` objects within a `ProvGigaList`.
#'
#' @export
getEmbeddings <- function(
    con, parallel = TRUE, layer = "last_layer_embed", ...
) {
    if (!is(con, "ProvGigaList"))
        con <- ProvGigaList(con, ...)

    levels <- vapply(
        con@listData, function(x) { x@level }, character(1L)
    )
    level <- unique(levels)

    if (!identical(unique(level),  "slide_level"))
        stop(
            "All ProvGiga objects must be 'slide_level' to extract embeddings."
        )

    emb_list <- lapply(
        con,
        embedding
    )
    stopifnot(
        identical(
            length(unique(lengths(emb_list))),
            1L
        )
    )
    do.call(rbind, emb_list)
}
