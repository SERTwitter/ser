#' Download, update, and upload SER twitter data
#'
#' `action_collect_twitter_data()` handles Twitter data collection related to
#' the SER account, primarily used in [`action_deploy_dashboard()`]. It
#' downloads, updates, and uploads the data, which is stored on Google Drive.
#'
#' @param path Path to data
#' @param google_drive_auth A Google Drive token
#'
#' @return invisibly, `path`
#' @export
download_twitter_data <- function(path = ".", google_drive_auth = drive_auth_token()) {
  path <- normalizePath(path, mustWork = FALSE))
  if (!fs::dir_exists(path)) fs::dir_create(path)
  googledrive::drive_auth(path = google_drive_auth)

  googledrive::drive_download(
    googledrive::as_id("1X6advdBAjtKc3_x16FNRyUVRh0aFZWNR"),
    file.path(path, "ser_mentions.Rds"),
    overwrite = TRUE
  )
  googledrive::drive_download(
    googledrive::as_id("1uCRk_rfKnqmwo_1ceoOkV1vxPqBsDzuS"),
    file.path(path, "mentioners.Rds"),
    overwrite = TRUE
  )
  googledrive::drive_download(
    googledrive::as_id("1oGznVFtI1pR_tXoaAjRYBW1KctmTFflR"),
    file.path(path, "ser_tweets.Rds"),
    overwrite = TRUE
  )
  googledrive::drive_download(
    googledrive::as_id("1KeR32iLX0VbbUq7-Y3iDL2HMROqXk5m3"),
    file.path(path, "n_followers.Rds"),
    overwrite = TRUE
  )

  invisible(path)
}

#' @export
#' @rdname download_twitter_data
upload_twitter_data <- function(path = ".", google_drive_auth = drive_auth_token()) {
  path <- normalizePath(path)
  googledrive::drive_auth(path = google_drive_auth)

  googledrive::drive_update(
    googledrive::as_id("1X6advdBAjtKc3_x16FNRyUVRh0aFZWNR"),
    file.path(path, "ser_mentions.Rds")
  )
  googledrive::drive_update(
    googledrive::as_id("1uCRk_rfKnqmwo_1ceoOkV1vxPqBsDzuS"),
    file.path(path, "mentioners.Rds")
  )
  googledrive::drive_update(
    googledrive::as_id("1oGznVFtI1pR_tXoaAjRYBW1KctmTFflR"),
    file.path(path, "ser_tweets.Rds")
  )
  googledrive::drive_update(
    googledrive::as_id("1KeR32iLX0VbbUq7-Y3iDL2HMROqXk5m3"),
    file.path(path, "n_followers.Rds")
  )
}

#' @export
#' @rdname download_twitter_data
update_twitter_data <- function(path = ".", google_drive_auth = drive_auth_token()) {
  path <- normalizePath(path)
  googledrive::drive_auth(path = google_drive_auth)

  # read data ---------------------------------------------------------------
  ser_mentions <- readr::read_rds(file.path(path, "ser_mentions.Rds"))
  mentioners <- readr::read_rds(file.path(path, "mentioners.Rds"))
  ser_tweets <- readr::read_rds(file.path(path, "ser_tweets.Rds"))
  n_followers <- readr::read_rds(file.path(path, "n_followers.Rds"))

  # update data -------------------------------------------------------------
  ser_mentions_update <- rtweet::get_mentions(token = ser_token(), since_id = ser_mentions$status_id[1])
  mentioners_update <- rtweet::lookup_tweets(ser_mentions_update$status_id, token = ser_token())
  ser_tweets_update <- rtweet::get_timeline("societyforepi", n = 1e4, token = ser_token())

  if (lubridate::today() %nin% n_followers$date) {
    followers <- rtweet::get_followers("societyforepi", n = 1e5, token = ser_token())
    n_followers_new <- data.frame(
      date = lubridate::today(),
      n_followers = nrow(followers)
    )
    n_followers <- rbind(n_followers, n_followers_new)
  }

  # bind updated data to existing data --------------------------------------
  ser_mentions <- rtweet::do_call_rbind(list(ser_mentions_update, ser_mentions))
  mentioners <- rtweet::do_call_rbind(list(mentioners_update, mentioners))
  ser_tweets <- dplyr::anti_join(ser_tweets_update, ser_tweets, by = "status_id") %>%
    list(ser_tweets) %>%
    rtweet::do_call_rbind()

  # re-write data -----------------------------------------------------------
  readr::write_rds(ser_mentions, file.path(path, "ser_mentions.Rds"))
  readr::write_rds(mentioners, file.path(path, "mentioners.Rds"))
  readr::write_rds(ser_tweets, file.path(path, "ser_tweets.Rds"))
  readr::write_rds(n_followers, file.path(path, "n_followers.Rds"))

  invisible(path)
}

#' @export
#' @rdname download_twitter_data
action_collect_twitter_data <- function(path = ".", google_drive_auth = drive_auth_token()) {
  path <- normalizePath(path)
  download_twitter_data(path = path, google_drive_auth = google_drive_auth)
  update_twitter_data(path = path, google_drive_auth = google_drive_auth)
  upload_twitter_data(path = path, google_drive_auth = google_drive_auth)

  invisible(path)
}
