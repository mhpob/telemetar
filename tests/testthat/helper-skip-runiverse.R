skip_test_on_runiverse <- function() {
  skip_if(
    !is.na(Sys.getenv("MY_UNIVERSE", unset = NA)),
    "On R-universe."
  )
}
