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
expect_true(all(grepl(imageFeatureTCGA:::.BASE_URL, urls)))
