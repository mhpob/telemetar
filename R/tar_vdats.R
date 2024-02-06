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
    csv_outdir,
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



#' Convert VDAT to CSV and track
#' @param vdat_batch a batch of VDAT file paths
#' @param csv_outdir file path to the output directory
#'
#' @returns character vector of directory file paths holding VDAT-exported CSVs
#'
#' @keywords internal vdat
tar_vdat_dir <- function(vdat_batch, csv_outdir){
  # Read files into the elements of a list
  for(i in seq_along(vdat_batch)){
    rvdat::vdat_to_folder(
      vdata_file = vdat_batch[i],
      outdir = csv_outdir,
      quiet = TRUE
    )
  }

  list.dirs(csv_outdir)

}


#' Read VDAT data into a merged list by data type
#' @param vdat_dir directory of VDAT-exported CSVs
#'
#' @returns list of data types merged across receiver VDAT files in `vdat_dir`
#'
#' @keywords internal vdat
vdat_read_in <- function(vdat_dir){
  # Read files into the elements of a list
  data_by_receiver <- lapply(
    vdat_dir,
    FUN = function(x){
      vdat_csvs <- list.files(x, pattern = "\\.csv$", full.names = TRUE)
      data_csv <- lapply(
        vdat_csvs,
        data.table::fread,
        sep = ",",
        fill = T,
        skip = 2,
        # rename columns
        col.names = function(x){
          tolower(gsub('and|UTC|[) (\\.]', '', x))
        },
        # some columns have no info, which causes class clashes in
        #   data.table::rbindlist. Import all as character to skirt around this
        colClasses = 'character'
      )
      names(data_csv) <- gsub("\\.csv$", "", basename(vdat_csvs))

      data_csv
    }
  )

  # Select only this files with something in them
  data_by_receiver <- data_by_receiver[sapply(data_by_receiver, length) > 0]

  # Pull out the names of the different data types
  data_names <- sapply(data_by_receiver, names) |> unlist() |> unique()

  # Merge the different data types together
   data_by_type <- lapply(
    data_names,
    FUN = function(x){
      hold <- lapply(data_by_receiver, `[[`, x) |>
        data.table::rbindlist(use.names = TRUE, fill = TRUE)

      # Fastest thing is to write and re-import to guess classes
      #  utils::type.convert doesn't guess times correctly
      data.table::fwrite(hold, file.path(tempdir(), 'hold.csv'))
      hold <- data.table::fread(file.path(tempdir(), 'hold.csv'))
    })

  # clean up files
  unlink(file.path(tempdir(), 'hold.csv'))

  names(data_by_type) <- data_names

  data_by_type
}

