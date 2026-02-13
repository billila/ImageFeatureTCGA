# Test ProvGigaList class and methods

# Get test URLs
slide_urls <- getCatalog("provgigapath") |>
  dplyr::filter(level == "slide_level", Project.ID == "TCGA-UVM") |>
  dplyr::slice(1:3) |>
  getFileURLs()

# Test ProvGigaList constructor
pgl <- ProvGigaList(slide_urls)
expect_inherits(pgl, "ProvGigaList")
expect_inherits(pgl, "SimpleList")
expect_equal(length(pgl), 3)
expect_true(pgl@are_URLs)

# Test all elements are ProvGiga
expect_true(all(vapply(pgl, function(x) is(x, "ProvGiga"), logical(1L))))

# Test path method
paths <- path(pgl)
expect_inherits(paths, "character")
expect_equal(length(paths), 3)
expect_true(all(grepl("^https://store.cancerdatasci.org", paths)))

# Test import method
old <- options(BiocFileCache.cache = tempdir())
on.exit(options(old))

imported <- import(pgl, redownload = FALSE)
expect_inherits(imported, "SummarizedExperiment")
expect_equal(ncol(imported), 3)
expect_true(
    all(
        c("slideName", "tumorType", "fileName", "patientIds", "sampleIds") %in%
            names(S4Vectors::metadata(imported))
    )
)
