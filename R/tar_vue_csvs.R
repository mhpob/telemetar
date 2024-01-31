#'
#' @export
tar_vue_csvs <- function(csv_dirs){
  #if one dir, batch
  # if >1,

  track_files <-
    tarchetypes::tar_files_input_raw(
      name = 'tracked',
      files = csv_dirs
    )

  read_files <-
    targets::tar_target_raw(
      name = 'data',
      command = quote(telemetar:::csv_read_in(tracked)),
      pattern = quote(map(tracked)),
      format = 'qs'
    )
  list(track_files, read_files)
}


csv_read_in <- function(csv_dir){
  detections <- list.files(csv_dir, full.names = T, pattern = '^VR.*\\.csv')

  if(length(csv_dir) == 0){
    data.table::data.table()
  } else {
    # Read files into the elements of a list
    detections <- lapply(
      detections,
      data.table::fread,
      fill = T,
      # rename columns
      col.names = function(x){
        tolower(gsub('and|UTC|[) (\\.]', '', x))
      }
    )


    # Bind list together into a data.table
    detections <- data.table::rbindlist(detections)

    detections
  }
}



