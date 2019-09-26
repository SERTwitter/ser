#' Create and run SER scripts
#'
#' `source_ser()` runs the available scripts in the ser package.
#' `use_ser_script()` sets up a new script to set deply, which is added to
#' `inst/scripts` in the package. `scripts_ls()` lists the currently available
#' scripts.
#'
#' @param name The name of the script (without the `.R` extension)
#' @export
source_ser <- function(name) {
  name <- stringr::str_remove(name, "\\.R")
  name <- paste0(name, ".R")
  file <- file.path("scripts", name)
  path <- system.file(file, package = "ser", mustWork = TRUE)
  sys.source(path, envir = parent.frame())
}

#' @export
#' @rdname source_ser
use_ser_script <- function(name) {
  name <- stringr::str_remove(name, "\\.R")
  name <- paste0(name, ".R")
  path <- file.path("inst", "scripts", name)
  fs::file_create(path)
  usethis::ui_done(paste("Writing", name))
  rstudioapi::navigateToFile(path)
}

#' @export
#' @rdname source_ser
scripts_ls <- function(name) {
  system.file("scripts", package = "ser") %>%
    fs::dir_ls() %>%
    fs::path_ext_remove() %>%
    fs::path_file()
}
