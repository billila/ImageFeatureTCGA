.TYPE_MAP <- data.frame(
    type = seq(0L, 5L),
    label = c("nolabe", "neopla", "inflam", "connec", "necros", "no-neo"),
    R = c(0L, 255L, 0L, 0L, 255L, 255L),
    G = c(0L, 0L, 255L, 0L, 255L, 165L),
    B = c(0L, 0L, 0L, 255L, 0L, 0L)
)

#' Import JSON file
#'
#' @importClassesFrom TENxIO TENxFile
#' @importFrom methods new is
#'
#' @exportClass HoverJSON
.HoverJSON <- setClass(
    Class = "HoverJSON",
    contains = "TENxFile"
)

#' @importFrom TENxIO TENxFile
#' @export
HoverJSON <- function(resource) {
    if (!is(resource, "TENxFile"))
        resource <- TENxIO::TENxFile(resource)
    .HoverJSON(resource)
}

#' @inheritParams BiocIO::import
#'
#' @importFrom BiocBaseUtils checkInstalled
#' @importFrom BiocIO import path
#'
#' @author Ilaria B., Marcel R.
#'
#' @examples
#' hov_json_file <- system.file(
#'     "extdata",
#'     "TCGA-J4-A6M7-01Z-00-DX1.0B8011EA-86D2-4439-B8AA-C6EC3D5985A0.json",
#'     mustWork = TRUE,
#'     package = "ImageFeatureTCGA"
#' )
#'
#' HoverJSON(hov_json_file) |>
#'     import()
#' @exportMethod import
setMethod("import", "HoverJSON", function(con, format, text, ...) {
    checkInstalled("jsonlite")
browser()
    file_path <- path(con)

    jmespath_query_simple <- "nuc.*.{
      x: centroid[0],
      y: centroid[1],
      type: type,
      type_prob: type_prob
    }"

    cell_ids <- j_query(file_path, "nuc | keys(@)", as = "R")

    # Extract the cell data values using the simplified query
    cell_data_list <- j_query(
        file_path,
        jmespath_query_simple,
        as = "R" # Output is a list of lists/vectors
    )

    # Add the cell_id column
    cells <- dplyr::bind_rows(cell_data_list) |>
        dplyr::mutate(cell_id = cell_ids, .before = 1)

    # Join with labels/colors
    cells <- dplyr::left_join(cells, .TYPE_MAP, by = "type")

    # Build SpatialExperiment
    assay_data <- matrix(0, nrow = 0, ncol = nrow(cells))

    spe <- SpatialExperiment::SpatialExperiment(
        assays = list(counts = assay_data),
        colData = cells,
        spatialCoords = as.matrix(cells[, c("x", "y")])
    )

    if (!missing(include_contours)) {
        message("Adding contour data to metadata...")
        contour_list <- lapply(nuclei, function(n) n$contour)
        metadata(spe)$contours <- contour_list
    }

    metadata(spe)$type_map <- .TYPE_MAP

    spe
})
