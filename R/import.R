.TYPE_MAP <- data.frame(
    type = seq(0L, 5L),
    label = c("nolabe", "neopla", "inflam", "connec", "necros", "no-neo"),
    R = c(0L, 255L, 0L, 0L, 255L, 255L),
    G = c(0L, 0L, 255L, 0L, 255L, 165L),
    B = c(0L, 0L, 0L, 255L, 0L, 0L)
)

#' @name HoverJSON
#'
#' @title Import Hovernet JSON files into a SpatialExperiment object
#'
#' @description The `HoverJSON` class represents Hovernet JSON files used for
#'   cell segmentation and classification in histopathology images. It extends
#'   the `TENxFile` class from the `TENxIO` package, allowing for efficient
#'   handling of large JSON files. The class includes a slot to indicate whether
#'   cell contours should be included in the metadata when importing the data.
#'
#' @importClassesFrom TENxIO TENxFile
#' @importFrom methods new is
#'
#' @exportClass HoverJSON
.HoverJSON <- setClass(
    Class = "HoverJSON",
    contains = "TENxFile",
    slots = c(
        contours = "logical"
    )
)

#' @rdname HoverJSON
#'
#' @description The `HoverJSON` constructor function creates an instance of the
#'   `HoverJSON` class. It takes a file path or URL to a Hovernet JSON file and
#'   an optional parameter to include cell contours in the metadata.
#'
#' @details Currently, the `HoverJSON` constructor function works on file paths
#'   but not on URLs. To work with remote files, please download them locally
#'   first. We are working to add direct URL support in future releases.
#'
#' @importFrom TENxIO TENxFile
#' @export
HoverJSON <- function(resource, contours = FALSE) {
    if (!is(resource, "TENxFile"))
        resource <- TENxIO::TENxFile(resource)
    .HoverJSON(resource, contours = contours)
}


#' @rdname HoverJSON
#'
#' @description The import method for `HoverJSON` reads the JSON file and
#'   represents the data as a `SpatialExperiment` object. It extracts cell
#'   centroid coordinates, cell types, and type probabilities, and optionally
#'   includes cell contours in the metadata. The resulting `SpatialExperiment`
#'   object contains the cell data in the `colData` slot and spatial coordinates
#'   in the `spatialCoords` slot of the object.
#'
#' @inheritParams BiocIO::import
#'
#' @importFrom BiocBaseUtils checkInstalled
#' @importFrom BiocIO import path
#' @importFrom rjsoncons j_query
#' @importFrom S4Vectors metadata metadata<-
#'
#' @author Ilaria B., Marcel R.
#'
#' @examplesIf interactive()
#' hov_json_file <- paste0(
#'     "https://store.cancerdatasci.org/hovernet/TCGA_OV/json/",
#'     "TCGA-23-1121-01Z-00-DX1.E2F25441-32C3-46BF-A845-CB4FA787E8CB.json.gz"
#' )
#' dest_json <- file.path(tempdir(), basename(hov_json_file))
#' download.file(hov_json_file, destfile = dest_json)
#'
#' HoverJSON(dest_json) |>
#'     import()
#' @exportMethod import
setMethod("import", "HoverJSON", function(con, format, text, ...) {
    json_path <- path(con)

    jmespath_query_simple <- "nuc.*.{
      x: centroid[0],
      y: centroid[1],
      type: type,
      type_prob: type_prob
    }"

    cell_ids <- j_query(json_path, "nuc | keys(@)", as = "R")

    # Extract the cell data values using the simplified query
    cell_data_list <- j_query(
        json_path,
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

    if (con@contours) {
        contour_list <- j_query(
            json_path,
            "nuc.*.contour",
            as = "R"
        )
        metadata(spe)$contours <- contour_list
    }

    metadata(spe)$type_map <- .TYPE_MAP

    spe
})
