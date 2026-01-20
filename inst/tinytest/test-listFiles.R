# if (!identical(Sys.getenv("NOT_CRAN"), "true")) {
#   exit_file("Skip online tests on CRAN")
# }

# Test listHoverNet
result <- listHoverNet()
expect_inherits(result, "data.frame")
expect_true(all(c("Filename", "Modified", "Size") %in% names(result)))
expect_true(nrow(result) > 0)
expect_false(any(grepl("^\\.\\.", result[["Filename"]])))

# Test different format - it takes too much time
# for (fmt in c("geojson", "h5ad", "json", "thumb")) {
#   result <- listHoverNet(format = fmt)
#   expect_inherits(result, "data.frame", info = fmt)
# }

# Test listProvGiga
result <- listProvGiga()
expect_inherits(result, "data.frame")
expect_true(all(c("Filename", "Modified", "Size") %in% names(result)))

# Test getCatalog
catalog <- getCatalog()
expect_inherits(catalog, "data.frame")
expect_true("pipeline" %in% names(catalog))
expect_true("format" %in% names(catalog))

# Test filter
cat_hov <- getCatalog(pipeline = "hovernet")
expect_true(all(cat_hov[["pipeline"]] == "hovernet"))

cat_h5ad <- getCatalog(format = "h5ad")
expect_true(all(cat_h5ad[["format"]] == "h5ad"))

# Test getFileURLs
urls <- getFileURLs(catalog[1:5, ])
expect_inherits(urls, "character")
expect_equal(length(urls), 5)
expect_true(all(grepl("^https://store.cancerdatasci.org", urls)))