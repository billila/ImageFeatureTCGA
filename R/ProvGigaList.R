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
    contains = "SimpleList"
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
#'   list of these elements.
#'
#' @export
ProvGigaList <- function(...) {
    dots <- S4Vectors::SimpleList(...)
    undots <- dots[[1L]]
    if (identical(length(dots), 1L)) {
        if (is.list(undots) || is(undots, "SimpleList")) {
            dots <- undots
        }
    }
    elem_chars <- vapply(dots, is.character, logical(1L))
    if (all(elem_chars))
        dots <- lapply(undots, ProvGiga)
    .ProvGigaList(dots)
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
    result <- lapply(con, import)
    names(result) <- basename(path(con))
    result
})

#' @rdname ProvGigaList
#'
#' @description The `getEmbeddings` function extracts and combines the
#'   embeddings from all `ProvGiga` objects within a `ProvGigaList`.
#'
#' @export
getEmbeddings <- function(con) {
    stopifnot(
        is(con, "ProvGigaList")
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
