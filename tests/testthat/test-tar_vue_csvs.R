# tar_test("batching works", {
#
# })

targets::tar_test("all files in one dir (to rule them all)", {
  ## Download example data
  dir.create('td', recursive = TRUE)
  download.file(
    file.path('https://raw.githubusercontent.com/ocean-tracking-network/glatos',
              'main/inst/extdata/VR2W_109924_20110718_1.csv'),
    'td/VR2W_109924_20110718_1.csv'
  )
  for(i in 2:12){
    file.copy(
      'td/VR2W_109924_20110718_1.csv',
      paste0('td/VR2W_109924_20110718_', i, '.csv')
    )
  }

  ## Run workflow
  targets::tar_script(
    list(
      telemetar::tar_vue_csvs(
        my_detections,
        'td'
      )
    )
  )
  targets::tar_make()

  ## Start tests

  manifest <- tar_manifest()
})

targets::tar_test("files in separate dirs (in the darkness bind them)", {
  ## Download example data
  dir.create('td/td2', recursive = TRUE)
  download.file(
    file.path('https://raw.githubusercontent.com/ocean-tracking-network/glatos',
              'main/inst/extdata/VR2W_109924_20110718_1.csv'),
    'td/VR2W_109924_20110718_1.csv'
  )
  for(i in 2:5){
    file.copy(
      'td/VR2W_109924_20110718_1.csv',
      paste0('td/VR2W_109924_20110718_', i, '.csv')
    )
    file.copy(
      'td/VR2W_109924_20110718_1.csv',
      paste0('td/td2/VR2W_109924_20110718_', i, '.csv')
    )
  }

  ## Run workflow
  targets::tar_script(
    list(
      telemetar::tar_vue_csvs(
        my_detections,
        'td'
      )
    )
  )
  targets::tar_make()

  ## Start tests
  out <- tar_manifest(my_detections)

  expect_equal(out$name, "my_detections")
  expect_equal(out$pattern, "map(my_detections_tracked)")
})
