

test_that("", {
  skip_on_ci()
  skip_test_on_runiverse()

  ## Run workflow
  targets::tar_script({
    source('tests/testthat/setup-testfiles.R')
    list(
      telemetar::tar_vdat_read(
        vdat_data,
        dirname(testfiles)[1],
        tempdir()
      )
    )
  })
  targets::tar_make(callr_function = NULL)

  ## Start tests
  out <- targets::tar_manifest(vdat_data)
})
