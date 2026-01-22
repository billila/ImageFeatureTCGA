#' Plot Multiple HoverNet Overlays in a Grid
#'
#' @description Creates a grid of HoverNet segmentation overlays for multiple
#'   samples, useful for comparing multiple tissue sections or slides.
#'
#' @param hovernet_list A list of `SpatialExperiment` objects or file paths to
#'   HoverNet JSON files.
#' @param json_paths Optional. A vector of paths/URLs to HoverNet JSON files,
#'   corresponding to `hovernet_list`. Only required if elements of
#'   `hovernet_list` are `SpatialExperiment` objects. Default is `NULL`.
#' @param titles Optional. A character vector of titles for each plot. 
#'   If `NULL`, uses the basename of JSON files. Default is `NULL`.
#' @param nrow Number of rows in the grid. Default is `NULL` (auto-determined).
#' @param ncol Number of columns in the grid. 
#'   Default is `NULL` (auto-determined).
#' @param ... Additional arguments passed to `plotHoverNetOverlay()`.
#'
#' @return A combined `ggplot` object with multiple overlay plots arranged in a
#'   grid.
#'
#' @examples
#' \dontrun{
#' json_files <- c(
#'   "path/to/sample1.json.gz",
#'   "path/to/sample2.json.gz",
#'   "path/to/sample3.json.gz"
#' )
#' plotHoverNetOverlayGrid(json_files, nrow = 1, ncol = 3)
#' }
#'
#' @export
plotHoverNetOverlayGrid <- function(
    hovernet_list,
    json_paths = NULL,
    titles = NULL,
    nrow = NULL,
    ncol = NULL,
    ...
) {
    
    n <- length(hovernet_list)
    
    if (is.null(json_paths)) {
        json_paths <- rep(list(NULL), n)
    }
    
    if (is.null(titles)) {
        titles <- rep(list(NULL), n)
    }
    
    # Generate individual plots
    plot_list <- lapply(seq_len(n), function(i) {
        plotHoverNetOverlay(
            hovernet = hovernet_list[[i]],
            json_path = json_paths[[i]],
            title = titles[[i]],
            ...
        )
    })
    
    # Combine into grid
    cowplot::plot_grid(
        plotlist = plot_list,
        nrow = nrow,
        ncol = ncol,
        align = "hv"
    )
}