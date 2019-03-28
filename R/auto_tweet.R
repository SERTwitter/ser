# functions to post tweet depending on type
post_tweet_queue <- function(tweet_data = tweet_queue, twitter_token = ser_token) {
  tweet <- tweet_data %>% 
    dplyr::filter(!tweeted) %>% 
    dplyr::sample_n(1) %>% 
    dplyr::pull(text)
  
  tweet_data <- tweet_data %>% 
    dplyr::mutate(tweeted = ifelse(text == tweet, TRUE, tweeted))
  
  rtweet::post_tweet(tweet, token = twitter_token())
  
  invisible(tweet_data)
}

update_retweets <- function(twitter_token = ser_token) {
  ser_tweets <- rtweet::get_timeline("societyforepi", n = 1e5, token = twitter_token())
  ser_tweets %>% 
    dplyr::arrange(desc(retweet_count)) %>% 
    dplyr::filter(!is_retweet, !stringr::str_detect(text, regex("SERPlaylist|playlist|EpiSummerReads", ignore_case = TRUE))) %>% 
    head(8) %>% 
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
action_auto_tweet <- function(twitter_token = ser_token, google_drive_auth = "ttt.rds") {
  # Authorize Google Drive for cron job
  ttt <- googledrive::drive_auth(google_drive_auth)
  saveRDS(ttt, google_drive_auth)
  
  # download the existing tweet queue from google drive 
  tweet_csv_id <- googledrive::drive_find(pattern = "^tweet_queue", type = "spreadsheet") %>% 
    dplyr::pull(id) %>% 
    googledrive::as_id()
  googledrive::drive_download(tweet_csv_id, type = "csv", overwrite = TRUE)
  tweet_queue <- readr::read_csv("tweet_queue.csv")
  
  # do the same for the retweets queue  
  retweet_csv_id <- googledrive::drive_find(pattern = "retweet_queue", type = "spreadsheet") %>% 
    dplyr::pull(id) %>% 
    googledrive::as_id()
  googledrive::drive_download(retweet_csv_id, type = "csv", overwrite = TRUE)
  retweet_queue <- readr::read_csv("retweet_queue.csv", col_types = "cciil")
  
  # don't post on weekends
  todays_date <- lubridate::wday(Sys.Date(), label = TRUE) %>% 
    as.character()
  if (todays_date %in% c("Mon", "Tue", "Wed", "Thu", "Fri")) {
    post_tweet_of_type <- post_tweet_queue
  } else {
    post_tweet_of_type <- blackout_tweet
  }
  
  # 1/10 days, retweet a popular SER tweet instead of posting a new one
  retweet_day <- sample(c(TRUE, FALSE), 1, prob = c(.1, .9))
  if (retweet_day) post_tweet_of_type <- post_retweet
  
  # check that it's not a blackout date
  # if it is, don't post anything
  blackout_id <- googledrive::drive_find(pattern = "tweet_blackout", type = "spreadsheet") %>% 
    dplyr::pull(id) %>% 
    googledrive::as_id()
  googledrive::drive_download(blackout_id, type = "csv", overwrite = TRUE)
  tweet_blackout <- readr::read_csv("tweet_blackout.csv", col_types = list(date = readr::col_date("%m/%d/%Y")))
  blackout <- lubridate::today() %in% tweet_blackout$date
  if (blackout) post_tweet_of_type <- blackout_tweet
  
  # post tweet and return updated data
  if (retweet_day) {
    retweet_queue <- post_tweet_of_type()
  } else { 
    tweet_queue <- post_tweet_of_type()
  }
  
  if (all(tweet_queue$tweeted)) tweet_queue$tweeted <- FALSE
  
  # update tweet and retweet queues
  googledrive::write_csv(tweet_queue, "tweet_queue.csv")
  googledrive::drive_update(tweet_csv_id, "tweet_queue.csv")
  googledrive::write_csv(retweet_queue, "retweet_queue.csv")
  googledrive::drive_update(retweet_csv_id, "retweet_queue.csv")
  
  # return updated tweet queue
  invisible(tweet_queue)
}