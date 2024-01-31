#'
#' @export
tar_vdat_read <- function(vrl_dirs){
  track_vdat <-
    tarchetypes::tar_files_input_raw(
      name = 'tracked',
      files = vrl_dirs
    )

  convert_vdat <-
    targets::tar_target_raw(
      name = "vdat_csv",
      command = quote(telemetar::tar_vdat_dir(tracked)),
      pattern = quote(map(tracked)),
      format = 'qs'
    )

  read_vdat <-
    targets::tar_target_raw(
      name = 'data',
      command = quote(telemetar:::vrl_read_in(vdat_csv)),
      pattern = quote(map(vdat_csv)),
      format = 'qs'
    )
  list(track_vdat, convert_vdat, read_vdat)
}




#' @export
tar_vdat_dir <- function(vdat_dir){
  vdats <- list.files(vdat_dir, full.names = T,
                      pattern = '^[VH]R.{2,3}_.*(\\.vrl|\\.vdat)')
  ## parse vrl, read, qs the list for each file?
  td <- file.path(tempdir(), '')
  rvdat::vdat_to_folder(vdat_dir,)

}



vrl_read_in <- function(vrl_dir){
  vrls <- list.files(vrl_dir, full.names = T,
                     pattern = '^[VH]R.{2,3}_.*(\\.vrl|\\.vdat)')

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