#' Dynamic branching over VUE/VDAT-exported CSV detection files.
#'
#' @inheritParams tarchetypes::tar_files_input
#' @param csv_dirs 	Nonempty character vector of known existing directories of
#'  CSV files to track for changes.
#' @param pattern a regular expression to search for the applicable CSV files.
#'  Defaults to "`^[VH]R.*\\.csv$`".
#' @param batch_size Positive integer of length 1, number of files to partition
#'  into a batch. The default is ten files per batch.
#'
#' @examples
#'
#' targets::tar_dir({
#'   ## Download example data
#'   download.file(
#'     file.path('https://raw.githubusercontent.com/ocean-tracking-network/glatos',
#'               'main/inst/extdata/VR2W_109924_20110718_1.csv'),
#'     'VR2W_109924_20110718_1.csv'
#'   )
#'
#'   for(i in 2:12){
#'     file.copy(
#'       'VR2W_109924_20110718_1.csv',
#'       paste0('VR2W_109924_20110718_', i, '.csv')
#'     )
#'   }
#'
#'   ## Run workflow
#'   targets::tar_script({
#'     list(
#'       telemetar::tar_vue_csvs(
#'         my_detections,
#'         getwd()
#'       )
#'     )
#'   })
#'
#'   targets::tar_make(callr_function = NULL)
#'
#' })
#'
#' @export
tar_vue_csvs <- function(
    name,
    csv_dirs,
    pattern = "^[VH]R.*\\.csv$",
    batch_size = 10,
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
  name_files <- paste0(name, '_csv')
  sym_files <- as.symbol(name_files)

  # Recursively list files
  csv_files <- list.files(csv_dirs, pattern = pattern,
                          recursive = TRUE, full.names = TRUE) |>
    unique()


  # Batch into groups of 10 or fewer
  batches <- file_batcher(files = csv_files, batch_size = batch_size)

  # Create the target factory
  track_files <-
    tarchetypes::tar_files_input_raw(
      name = name_files,
      files = csv_files,
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

  # Export targets
  list(track_files, read_files)
}



#' Read-in function
#'
#' @param csv_batch a batch of vdat CSV files
#'
#' @keywords internal
csv_read_in <- function(csv_batch){
  # Read files into the elements of a list
  lapply(
    csv_batch,
    data.table::fread,
    fill = T,
    # rename columns
    col.names = function(x){
      tolower(gsub('and|UTC|[) (\\.]', '', x))
    }
  ) |>
    data.table::rbindlist()
}
