#'
#' @export
tar_vue_csvs <- function(
    name,
    csv_dirs,
    batches = length(list.dirs(csv_dirs)),
    format = c("file", "file_fast", "url", "aws_file"),
    repository = targets::tar_option_get("repository"),
    iteration = targets::tar_option_get("iteration"),
    error = targets::tar_option_get("error"),
    memory = targets::tar_option_get("memory"),
    garbage_collection = targets::tar_option_get("garbage_collection"),
    priority = targets::tar_option_get("priority"),
    resources = targets::tar_option_get("resources"),
    cue = targets::tar_option_get("cue")
){
  name <- targets::tar_deparse_language(substitute(name))
  name_files <- paste0(name, '_tracked')
  sym_files <- as.symbol(name_files)

  dirs <- list.dirs(csv_dirs)


  # If all files are in one folder, batch it into groups of 10 or fewer
  if(length(dirs) == 1){
    batches <-  ceiling(
      length(
        list.files(csv_dirs, recursive = TRUE)
      ) / 10
    )
  } else {
    # or use the sub-directories as batches
    ### TBD: loop the batching above on subdirs to have 10 or fewer files?
    batches <- length(dirs)
  }



  track_files <-
    tarchetypes::tar_files_input_raw(
      name = name_files,
      files = dirs,
      batches = batches
    )

  read_files <-
    targets::tar_target_raw(
      name = name,
      command = substitute(
        csv_read_in(files),
        env = list(csv_read_in = csv_read_in,
                   files = sym_files)
      ),
      pattern = as.expression(
        tarchetypes:::call_function("map", list(sym_files))
        ),
      format = 'qs'
    )

  list(track_files, read_files)
}

### read-in function
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
