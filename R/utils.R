#' Batch a vector of files
#'
#' @param files character vector of files
#'
#' @keywords internal
file_batcher <- function(files, batch_size){
  ceiling(
    length(files) / batch_size
  )
}
