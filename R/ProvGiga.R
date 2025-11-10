#' @name ProvGiga
#'
#' @title Import ProvGiga slide-level data into a Bioconductor class object
#'
#' @description The `ProvGiga` class represents ProvGiga slide-level CSV files
#'   containing embeddings for histopathology images. It extends the `TENxFile`
#'   class from the `TENxIO` package, allowing for efficient handling of large
#'   CSV files. The class includes slots to specify the output class when
#'   importing the data, either `SpatialExperiment` or
#'   `SpatialFeatureExperiment`, the tumor type, and whether the resource is a
#'   URL.
#'
#' @slot tumorType `character(1)` specifying the tumor type associated with the
#'   `ProvGiga` data.
#'
#' @slot is_url `logical(1)` indicating whether the resource is a URL.
#'
#' @importClassesFrom TENxIO TENxFile
#' @importFrom methods new is
#'
#' @exportClass ProvGiga
.ProvGiga <- setClass(
    Class = "ProvGiga",
    contains = "TENxFile",
    slots = c(
        tumorType = "character",
        is_url = "logical"
    )
)

#' @rdname ProvGiga
#'
#' @description The `ProvGiga` constructor function creates an instance of the
#'   `ProvGiga` class. The `resource` argument can be either a file path or URL
#'   to a ProvGiga CSV file. The `tumorType` parameter specifies the tumor
#'   type associated with the ProvGiga data.
#'
#' @param resource `character(1)` the file path or URL to the ProvGiga CSV file,
#'   or a `TENxFile` object.
#'
#' @param tumorType `character(1)` specifying the tumor type associated with the
#'   `ProvGiga` data. Required if `resource` is a local file (file path).
#'
#' @details The `ProvGiga` constructor function can import file paths, URLs, and
#'   `TENxFile` objects. If a local file path is provided, the `tumorType`
#'   parameter must be specified to indicate the tumor type associated with the
#'   ProvGiga data. If a URL is provided, the tumor type is inferred from the
#'   URL structure.
#'
#' @importFrom BiocBaseUtils isScalarCharacter
#' @importFrom TENxIO TENxFile
#' @importFrom methods is
#'
#' @returns * `ProvGiga`: An object of class `ProvGiga`.
#' * `import`: A `tibble` containing slide-level embeddings along with slide
#'   names and tumor type.
#'
#' @export
ProvGiga <- function(
    resource,
    tumorType
) {
    stopifnot(
        isScalarCharacter(resource) || is(resource, "TENxFile")
    )
    path_extract <- if (is(resource, "TENxFile")) path else I
    is_url <- .is_url(path_extract(resource))
    if (!is_url && missing(tumorType))
        stop("'tumorType' must be provided for local files.")
    else if (is_url)
        tumorType <- basename(dirname(path_extract(resource)))
    if (!is(resource, "TENxFile"))
        resource <- TENxIO::TENxFile(resource)
    .ProvGiga(
        resource, is_url = is_url, tumorType = tumorType
    )
}

#' @rdname ProvGiga
#'
#' @section `import`: The `import` method for `ProvGiga` objects reads the ProvGiga
#'  CSV file and extracts slide-level embeddings along with the slide names and
#'  tumor type. The embeddings are returned as a `tibble` with columns for
#'  slide names, tumor type, and embedding values.
#'
#' @inheritParams BiocIO::import
#'
#'
#' @importFrom BiocIO import path
#'
#' @author Ilaria B., Marcel R.
#'
#' @examplesIf interactive()
#' prov_url <- paste0(
#'     "https://store.cancerdatasci.org/provgigapath/slide_level/",
#'     "TCGA_ACC/",
#'     "TCGA-OR-A5JJ-01Z-00-DX1.459B5DFE-47B1-426F-B009-7664C1B6FEEC.csv.gz"
#' )
#' prov_file <- file.path(tempdir(), basename(prov_url))
#' download.file(prov_url, destfile = prov_file)
#'
#' ProvGiga(prov_file, tumorType = "TCGA_ACC") |>
#'     import()
#'
#' ProvGiga(prov_url) |>
#'     import()
#' @exportMethod import
setMethod("import", "ProvGiga", function(con, format, text, ...) {
    prov_path <- path(con)
    tumorType <- con@tumorType

    if (con@is_url)
        prov_path <- .cache_url_file(prov_path)

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
})

