build_html <- function(.data, .message) {
  if (nrow(.data) == 0) {
    return(glue::glue("<h2> No {.message} today. </h2>"))
  }

  table_html <- .data %>%
    gt::gt() %>%
    gt::as_raw_html()

  glue::glue("<h2> Today's {.message}: </h2> \n {table_html}")
}

get_os <- function() {
  Sys.info()["sysname"] %>%
    stringr::str_replace("Darwin", "mac") %>%
    stringr::str_replace("linux-gnu", "linux")
}

get_ny_tz <- function() {
  # "America/New_York" for linux, "America/New_york" for mac
  ifelse(get_os() == "mac", "America/New_york", "America/New_York")
}

#' Email Daily Summary of SER Tweets
#'
#' `action_email_summary()` handles daily summaries of tweets made on the SER
#' account. This function emails an HTML table (using the gt package) of the
#' tweets and retweets for the day to a list of recipients. It returns a
#' character vector containing the email message that it sent. Requires Gmail
#' and Twitter authorization.
#'
#' @param twitter_token an rtweet token for the SER app
#' @param recipients a vector of email addresses to blind copy the email to
#'
#' @return the email to be sent, a character vector
#' @export
action_email_summary <- function(recipients, twitter_token = ser_token) {
  gmailr::gm_auth_configure(gmail_id(), gmail_secret())
  gmailr::gm_auth(email = gmail_email(), scopes = "compose", token = gmailr::gm_oauth_app())

  yesterday <- lubridate::today() - lubridate::days(1)

  ser_tweets <- rtweet::get_timeline("societyforepi", n = 100, token = twitter_token())
  todays_tweets <- ser_tweets %>%
    # set time zone to New York
    dplyr::mutate(date = lubridate::ymd_hms(created_at, tz = "UTC") %>% lubridate::with_tz(get_ny_tz())) %>%
    dplyr::filter(lubridate::floor_date(date, "day") == yesterday)

  original_tweets <- todays_tweets %>%
    dplyr::filter(!is_retweet) %>%
    dplyr::select(Time = date, `Tweet Text` = text)

  retweets <- todays_tweets %>%
    dplyr::filter(is_retweet) %>%
    dplyr::select(Time = date, `Retweeted From` = retweet_screen_name, `Retweet Text` = text)

  email_msg <- paste(
    "<h1> Tweets from @societyforepi:",
    yesterday,
    "</h1> \n",
    build_html(original_tweets, "tweets"),
    "\n",
    build_html(retweets, "retweets")
  )

  gmailr::mime() %>%
    gmailr::to("ser.twitteracct@gmail.com") %>%
    gmailr::from("ser.twitteracct@gmail.com") %>%
    gmailr::bcc(recipients) %>%
    gmailr::subject(paste("SER Tweet Summary:", yesterday)) %>%
    gmailr::html_body(email_msg) %>%
    gmailr::send_message()

  invisible(email_msg)
}
