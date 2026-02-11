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
    args <- list(...)
    redownload <- args[["redownload"]] %||% FALSE
    parallel <- args[["parallel"]] %||% FALSE

    levels <- vapply(
        con@listData, function(x) { x@level }, character(1L)
    )
    level <- unique(levels)

    split_list <- embeddingStack(
        con, levels = levels, redownload = redownload, parallel = parallel
    )

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
