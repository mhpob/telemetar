# Create tempdir for test files
td <- file.path(
  tempdir(),
  "test_files"
)

dir.create(
  td
)

# Use test files from glatos' dev branch
## Parse /dev/inst/extdata/detection_files_raw directory, pick vdat files,
##  and make their download URLs
testfiles <- "https://github.com/ocean-tracking-network/glatos/tree/dev/inst/extdata/detection_files_raw" |>
  readLines(warn = FALSE) |>
  strsplit("path")
testfiles <- testfiles[[1]] |>
  grep("detection_files_raw.*\\.v", x = _, value = T) |>
  strsplit('[:,"]') |>
  lapply(function(.) .[grepl("inst.*\\.v", .)]) |>
  unlist()
testfiles <- testfiles[!duplicated(gsub("[_ ].*\\.", "", basename(testfiles)))]
testfiles <- testfiles |>
  file.path("https://github.com/ocean-tracking-network/glatos/raw/dev/",
            ... = _
  ) |>
  URLencode()

## Download files into tempdir
for (i in seq_along(testfiles)) {
  download.file(testfiles[i],
                destfile = file.path(
                  td,
                  URLdecode(
                    basename(
                      testfiles[i]
                    )
                  )
                ),
                mode = "wb", quiet = TRUE
  )
}


testfiles <- list.files(td, full.names = TRUE)

rm(i, td)
