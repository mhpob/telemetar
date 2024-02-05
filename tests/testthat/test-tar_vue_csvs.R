targets::tar_test("all files in one dir (to rule them all)", {
  ## Download example data
  dir.create('td')
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
  targets::tar_make(callr_function = NULL)

  ## Start tests

  out <- targets::tar_manifest()

  expect_equal(out$name, "my_detections")
  expect_equal(out$pattern, "map(my_detections_tracked)")
  expect_true(grepl('csv_dir', out$command))

  # Branching works
  expect_false(any(is.na(tar_branch_names(my_detections, 1:2))))
  expect_true(is.na(tar_branch_names(my_detections, 3)))

  # Correct types
  md <- targets::tar_load(my_detections)
  expect_s3_class(md, c('data.table', 'data.frame'), exact = TRUE)
  expect_named(md, c('datetime', 'receiver', 'transmitter', 'transmittername',
                     'transmitterserial', 'sensorvalue', 'sensorunit',
                     'stationname', 'latitude', 'longitude'))

  md_files <- targets::tar_read(my_detections_tracked)
  expect_length(md_files, 3)
  expect_type(md_files, 'character')

  md_files_list <- targets::tar_read(my_detections_tracked_files)
  expect_length(md_files_list, 3)
  expect_type(md_files_list, 'list')


  # unlink('td', recursive = TRUE) # only needed for interactive testing
})




targets::tar_test("files in separate dirs (in the darkness bind them)", {
  ## Download example data
  dir.create('td/td2/td3', recursive = TRUE)
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
    file.copy(
      'td/VR2W_109924_20110718_1.csv',
      paste0('td/td2/td3/VR2W_109924_20110718_', i, '.csv')
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
  targets::tar_make(callr_function = NULL)

  ## Start tests
  out <- targets::tar_manifest(my_detections)

  expect_equal(out$name, "my_detections")
  expect_equal(out$pattern, "map(my_detections_tracked)")
  expect_true(grepl('csv_dir', out$command))

  # Branching works
  expect_false(any(is.na(tar_branch_names(my_detections, 1:3))))
  expect_true(is.na(tar_branch_names(my_detections, 4)))

  # Correct types
  md <- targets::tar_load(my_detections)
  expect_s3_class(md, c('data.table', 'data.frame'), exact = TRUE)
  expect_named(md, c('datetime', 'receiver', 'transmitter', 'transmittername',
                      'transmitterserial', 'sensorvalue', 'sensorunit',
                      'stationname', 'latitude', 'longitude'))

  md_files <- targets::tar_read(my_detections_tracked)
  expect_length(md_files, 3)
  expect_type(md_files, 'character')

  md_files_list <- targets::tar_read(my_detections_tracked_files)
  expect_length(md_files_list, 3)
  expect_type(md_files_list, 'list')


  # unlink('td', recursive = TRUE) # only needed for interactive testing
})
