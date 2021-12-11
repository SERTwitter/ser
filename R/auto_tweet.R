# functions to post tweet depending on type
post_tweet_library <- function(tweet_data = tweet_library,
                               past_tweets = tweet_hist_ids,
                               twitter_token = ser_token) {
  tweet_data <- tweet_data %>%
    dplyr::mutate(
      id_transform =
        stringr::str_remove_all(Timestamp, pattern = "\\s|:|/")
    )

  id_check <- tweet_data %>%
    dplyr::filter(!id_transform %in% past_tweets)

  if (nrow(id_check) == 0) {
    tweet_data <- tweet_data %>%
      dplyr::sample_n(1)
    restart_history <- TRUE
  } else {
    tweet_data <- id_check %>%
      dplyr::sample_n(1)
    restart_history <- FALSE
  }

  rtweet::post_tweet(tweet_data$Tweet, token = twitter_token)

  invisible(
    list(
      restart_history = restart_history,
      just_tweeted = tweet_data$id_transform
    )
  )
}

update_retweets <- function(twitter_token = ser_token) {
  ser_tweets <- rtweet::get_timeline("societyforepi", n = 1e5, token = twitter_token())
  ser_tweets %>%
    dplyr::arrange(desc(retweet_count)) %>%
    dplyr::filter(!is_retweet, !stringr::str_detect(text, stringr::regex("SERPlaylist|playlist|EpiSummerReads", ignore_case = TRUE))) %>%
    utils::head(8) %>%
    dplyr::select(text, status_id, favorite_count, retweet_count) %>%
    dplyr::mutate(tweeted = FALSE)
}

post_retweet <- function(tweet_data = retweet_queue, twitter_token = ser_token) {
  if (all(tweet_data$tweeted)) tweet_data <- update_retweets()

  tweet_id <- tweet_data %>%
    dplyr::filter(!tweeted) %>%
    dplyr::sample_n(1) %>%
    dplyr::pull(status_id)

  tweet_data <- tweet_data %>%
    dplyr::mutate(tweeted = ifelse(status_id == tweet_id, TRUE, tweeted))

  rtweet::post_tweet(retweet_id = tweet_id, token = twitter_token())

  invisible(tweet_data)
}

blackout_tweet <- function(tweet_data = tweet_queue) {
  invisible(tweet_data)
}

get_day <- function() {
  lubridate::wday(Sys.Date(), label = TRUE) %>%
    as.character()
}

#' Post SER tweets from the tweet queue Monday through Friday
#'
#' `action_auto_tweet()` handles daily tweeting on the SER account. It randomly pulls
#' one tweet from the tweet queue per day to post. It cycles through each tweet
#' before posting a tweet again. Additionally, there is a 1 in 10 chance that it
#' will instead retweet a popular SER tweet. This function will not post
#' anything if it is a blackout date. It causes several side effects, including
#' downloading the tweet and retweet queue, posting tweets, and updating the
#' files on Google Drive. Requires Google Drive and Twitter authorization.
#'
#' @param twitter_token an rtweet token for the SER app
#' @param google_drive_auth the name of the google drive authorization file
#'
#' @return a data frame containing the updated tweet queue
#'
#' @export
action_auto_tweet <- function(twitter_token = ser_token,
                              google_drive_auth = drive_auth_token(),
                              todays_date = get_day()) {

  # Authorize Google Drive for cron job
  # previous code
  # ttt <- googledrive::drive_auth(google_drive_auth)
  # if (!is.null(google_drive_auth)) saveRDS(ttt, google_drive_auth)
  googledrive::drive_auth(path = google_drive_auth)

  # download the existing tweet form entries from google drive
  tweet_library_id <- googledrive::drive_find(
    pattern = "ser_tweet_library",
    type = "spreadsheet"
  ) %>%
    dplyr::pull(id) %>%
    googledrive::as_id()
  googledrive::drive_download(tweet_library_id, type = "csv", overwrite = TRUE)
  tweet_library <- readr::read_csv("ser_tweet_library.csv")

  # download tweet history
  tweet_hist_id <- googledrive::drive_find(
    pattern = "ser_tweet_history",
    type = "spreadsheet"
  ) %>%
    dplyr::pull(id) %>%
    googledrive::as_id()
  googledrive::drive_download(tweet_hist_id, type = "csv", overwrite = TRUE)
  tweet_hist <- readr::read_csv("ser_tweet_history.csv", col_types = "c")
  tweet_hist_ids <- tweet_hist$tweet_id

  # do the same for the retweets queue
  retweet_csv_id <- googledrive::drive_find(
    pattern = "retweet_queue",
    type = "spreadsheet"
  ) %>%
    dplyr::pull(id) %>%
    googledrive::as_id()
  googledrive::drive_download(retweet_csv_id, type = "csv", overwrite = TRUE)
  retweet_queue <- readr::read_csv("retweet_queue.csv", col_types = "cciil")


  # check date and choose tweet type
  if (todays_date %in% c("Mon", "Tue", "Wed", "Thu", "Fri")) {
    post_tweet_of_type <- post_tweet_library
  } else {
    post_tweet_of_type <- blackout_tweet
  }

  # 1/10 days, retweet a popular SER tweet instead of posting a new one
  retweet_day <- sample(c(TRUE, FALSE), 1, prob = c(.1, .9))
  if (retweet_day) post_tweet_of_type <- post_retweet(twitter_token = twitter_token)

  # check that it's not a blackout date
  # if it is, don't post anything
  blackout_id <- googledrive::drive_find(
    pattern = "tweet_blackout",
    type = "spreadsheet"
  ) %>%
    dplyr::pull(id) %>%
    googledrive::as_id()

  googledrive::drive_download(blackout_id, type = "csv", overwrite = TRUE)
  tweet_blackout <- readr::read_csv(
    "tweet_blackout.csv",
    col_types = list(date = readr::col_date("%m/%d/%Y"))
  )

  blackout <- lubridate::today() %in% tweet_blackout$date
  if (blackout) post_tweet_of_type <- blackout_tweet

  # post tweet and return updated data
  if (retweet_day) {
    retweet_queue <- post_tweet_of_type(retweet_queue)
  } else {
    tweet_library_status <- post_tweet_of_type(tweet_library, tweet_hist_ids, twitter_token)
  }

  if (tweet_library_status$restart_history) {
    tweet_hist <- dplyr::tibble(tweet_id = tweet_library_status$just_tweeted)
  } else {
    tweet_hist <- dplyr::tibble(
      tweet_id = c(tweet_hist_ids, tweet_library_status$just_tweeted)
    )
  }


  # update tweet and retweet queues
  readr::write_csv(tweet_hist, "ser_tweet_history.csv")
  googledrive::drive_update(tweet_hist_id, "ser_tweet_history.csv")
  readr::write_csv(retweet_queue, "retweet_queue.csv")
  googledrive::drive_update(retweet_csv_id, "retweet_queue.csv")

  # return updated tweet queue
  invisible(tweet_hist)
}
