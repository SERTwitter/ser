
#' Get tokens for SER functionality
#'
#' @return A Twitter or Google Drive token
#' @export
drive_auth_token <- function() {
  Sys.getenv("DRIVE_AUTH_TOKEN_PATH")
}

#' @export
#' @rdname drive_auth_token
ser_token <- function() {
  rtweet::create_token(
    "tweet_tokens_ser",
    consumer_key = Sys.getenv("SER_CONSUMER_KEY"),
    consumer_secret = Sys.getenv("SER_CONSUMER_SECRET"),
    access_token = Sys.getenv("SER_ACCESS_TOKEN"),
    access_secret = Sys.getenv("SER_ACCESS_SECRET"),
    set_renv = FALSE
  )
}

#' @export
#' @rdname drive_auth_token
sandbox_token <- function() {
  rtweet::create_token(
    "twitter_sandbox_test",
    consumer_key = Sys.getenv("SANDBOX_CONSUMER_KEY"),
    consumer_secret = Sys.getenv("SANDBOX_CONSUMER_SECRET"),
    access_token = Sys.getenv("SANDBOX_ACCESS_TOKEN"),
    access_secret = Sys.getenv("SANDBOX_ACCESS_SECRET"),
    set_renv = FALSE
  )
}

#' @export
#' @rdname drive_auth_token
rsconnect_auth <- function() {
  rsconnect::setAccountInfo(
    name = "societyforepi",
    token = Sys.getenv("SER_SHINYAPPS_TOKEN"),
    secret = Sys.getenv("SER_SHINYAPPS_SECRET")
  )
}
