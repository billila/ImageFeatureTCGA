library(ImageFeatureTCGA)

slides_url <- "https://store.cancerdatasci.org/provgigapath/slide_level/"
slides_df <- ImageFeatureTCGA:::.see_more_table(slides_url)
slideCodes <- slides_df[startsWith(slides_df[["Filename"]], "TCGA"), "Filename"] |>
    unlist() |>
    unname() |>
    gsub("/", "", fixed = TRUE, x = _)

tiles_url <- "https://store.cancerdatasci.org/provgigapath/tile_level/"
tiles_df <- ImageFeatureTCGA:::.see_more_table(tiles_url)
tileCodes <- tiles_df[startsWith(tiles_df[["Filename"]], "TCGA"), "Filename"] |>
    unlist() |>
    unname() |>
    gsub("/", "", fixed = TRUE, x = _)

allCodes <- union(slideCodes, tileCodes) |> sort()

TCGAcodesAvailable <- data.frame(
    diseaseCodes = allCodes,
    slide_level_available = allCodes %in% slideCodes,
    tile_level_available = allCodes %in% tileCodes,
    hover_available = allCodes %in% "TCGA_OV"
)

usethis::use_data(TCGAcodesAvailable, overwrite = TRUE)
