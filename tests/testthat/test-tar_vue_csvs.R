fls <- list.files('c:/users/darpa2/analysis/chesapeake-backbone/embargo/raw/20230912',
           pattern = "^VR.*\\.vrl$", full.names = T)[1:2]


  targets::tar_script(
    list(
      telemetar::tar_vue_csvs(
        'c:/users/darpa2/analysis/chesapeake-backbone/embargo/raw/20230912'
      )
    )
  )
  targets::tar_make()


test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
