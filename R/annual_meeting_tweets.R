# functions to post tweet depending on type
post_meeting_tweet <- function(tweet_data = meeting_tweet_queue, twitter_token = ser_token) {
  tweet <- tweet_data %>%
    dplyr::filter(!is.na(text)) %>%
    dplyr::sample_n(1) %>%
    dplyr::pull(text)

  rtweet::post_tweet(tweet, token = twitter_token())

  invisible(tweet_data)
}

#' Post tweets about the SER Annual Meeting
#'
#' `action_meeting_tweet()` handles yearly tweeting about the SER Annual
#' Meeting. It randomly pulls one tweet from the meeting tweet queue to post.
#' The function will run March to June, posting 3 tweets a week until May the 5
#' tweets a week until the meeting starts. This function will not post anything
#' if it is a blackout date. It causes several side effects, including
#' downloading the meeting tweet queue and posting tweets. Requires Google Drive
#' and Twitter authorization.
#'
#' @param period_start beginning of period to tweet about meeting
#' @param period_end end of period to tweet about meeting
#' @param twitter_token an rtweet token for the SER app
#' @param google_drive_auth the name of the google drive authorization file
#'
#' @return a data frame containing the updated meeting tweet queue
#'
#' @export
#' @importFrom lubridate %within%
action_meeting_tweet <- function(period_start = "2019-03-01", period_end = "2019-06-18",
                                 twitter_token = ser_token, google_drive_auth = "ttt.rds") {

  # Don't post in outside of the 3 months before the meeting
  pre_meeting_int <- lubridate::interval(lubridate::ymd(period_start), lubridate::ymd(period_end))
  if (!(Sys.Date() %within% pre_meeting_int)) {
    return(invisible(NULL))
  }

  # Authorize Google Drive for cron job
  ttt <- googledrive::drive_auth(google_drive_auth)
  saveRDS(ttt, google_drive_auth)

  # download the existing tweet queue from google drive
  tweet_csv_id <- googledrive::drive_find(pattern = "SER annual meeting sessions 2019", type = "spreadsheet") %>%
    dplyr::pull(id) %>%
    googledrive::as_id()
  googledrive::drive_download(tweet_csv_id, path = "meeting_tweet_queue.csv", overwrite = TRUE)
  meeting_tweet_queue <- readr::read_csv("meeting_tweet_queue.csv")
  names(meeting_tweet_queue) <- c("time", "text", "session_type")

  # check that it's not a blackout date
  # if it is, don't post anything
  blackout_id <- googledrive::drive_find(pattern = "tweet_blackout", type = "spreadsheet") %>%
    dplyr::pull(id) %>%
    googledrive::as_id()
  googledrive::drive_download(blackout_id, type = "csv", overwrite = TRUE)
  tweet_blackout <- readr::read_csv("tweet_blackout.csv", col_types = list(date = readr::col_date("%m/%d/%Y")))
  blackout <- lubridate::today() %in% tweet_blackout$date
  if (blackout) post_meeting_tweet <- blackout_tweet

  # post more often when closer to the meeting but not on weekends
  this_month <- lubridate::month(Sys.Date(), label = TRUE)
  last_6_weeks <- this_month %in% c("May", "Jun") & Sys.Date() < period_end
  tweet_days <- c("Mon", "Tue", "Wed", "Thu", "Fri")
  if (!last_6_weeks) tweet_days <- tweet_days[c(1, 3, 5)]
  todays_date <- lubridate::wday(Sys.Date(), label = TRUE) %>%
    as.character()

  # post tweet and return updated data
  if (todays_date %in% tweet_days) {
    meeting_tweet_queue <- post_meeting_tweet(meeting_tweet_queue)
  }

  # return updated tweet queue
  invisible(meeting_tweet_queue)
}
