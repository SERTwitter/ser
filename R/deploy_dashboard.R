#' Deploy the SER Tweet Dashboard to shinyapps.io
#'
#' `action_deploy_dashboard()` deploys the Twitter dashboard to `shinyapps.io`.
#' Use `create_dashboard()` to make a copy of the dashboard and download the
#' data without deploying.
#'
#' @param path The path where the dashboard exists or should be created
#' @param create Create the dashboard?
#'
#' @return Invisibly, `path`
#' @export
action_deploy_dashboard <- function(path = ".", create = TRUE) {
  path <- normalizePath(path)

  if (create) create_dashboard(path = path)

  rsconnect_auth()
  rsconnect::deployApp(appDir = file.path(path, "tweet_dashboard"), appName = "tweet_dashboard", forceUpdate = TRUE)

  invisible(path)
}

#' @export
#' @rdname action_deploy_dashboard
create_dashboard <- function(path = ".") {
  path <- normalizePath(path)
  if (!fs::dir_exists(path)) fs::dir_create(path)

  app_dir <- system.file(file.path("shiny_apps", "tweet_dashboard"), package = "ser", mustWork = TRUE)
  fs::dir_copy(app_dir, file.path(path, "tweet_dashboard"))

  download_twitter_data(file.path(path, "tweet_dashboard", "data"))

  invisible(path)
}
