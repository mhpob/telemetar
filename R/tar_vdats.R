#' Dynamic branching over VDAT files
#'
#'
#' @inheritParams tar_vue_csvs
#' @param vdat_dirs Nonempty character vector of known existing directories of
#'  VDAT files to track for changes.
#'
#' @examples
#' # example code
#'
#' @export
tar_vdat_read <- function(
    name,
    vdat_dirs,
    batch_size = 10,
    batches = NULL,
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

  # List unique files
  ## Recursively list files
  vdat_files <- list.files(vdat_dirs, pattern = "\\.(vrl|vdat)$",
                           recursive = TRUE, full.names = TRUE) |>
    unique()

  ## Drop RLD files
  vdat_files <- vdat_files[!grepl('-RLD_', vdat_files)]

  # Batch files
  batches <- file_batcher(files = vdat_files, batch_size = batch_size)

  # Create the target factory
  ## Track
  name_files <- paste0(name, '_vdat')

  track_vdat <-
    tarchetypes::tar_files_input_raw(
      name = name_files,
      files = vdat_files,
      batches = batches
    )

  ## Convert
  sym_files <- as.symbol(name_files)
  name_csv <- paste0(name, '_csv')

  convert_vdat <-
    targets::tar_target_raw(
      name = name_csv,
      command = substitute(
        tar_vdat_dir(files),
        env = list(
          tar_vdat_dir = tar_vdat_dir,
          files = sym_files
        )
      ),
      pattern = as.expression(
        call_function("map", list(sym_files))
      ),
      format = 'qs'
    )

  ## Read
  sym_csv <- as.symbol(name_csv)

  read_files <-
    targets::tar_target_raw(
      name = name,
      command = substitute(
        vdat_read_in(files),
        env = list(vdat_read_in = vdat_read_in,
                   files = sym_csv)
      ),
      pattern = as.expression(
        tarchetypes:::call_function("map", list(sym_csv))
      ),
      format = 'qs'
    )

  # Export target factory
  list(track_vdat, convert_vdat, read_vdat)
}




#' @export

#Notes to self:
# look at csv_read_in and adapt
tar_vdat_dir <- function(vdat_dir){
  vdats <- list.files(vdat_dir, full.names = T,
                      pattern = '^[VH]R.{2,3}_.*(\\.vrl|\\.vdat)')
  ## parse vrl, read, qs the list for each file?
  td <- file.path(tempdir(), '')
  rvdat::vdat_to_folder(vdat_dir,)

}



vdat_read_in <- function(vrl_dir){
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
