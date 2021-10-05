build_html <- function(.data, .message) {
  if (nrow(.data) == 0) {
    return(glue::glue("<h2> No {.message} today. </h2>"))
  }

  table_html <- .data %>%
    gt::gt() %>%
    gt::fmt_markdown(dplyr::vars(Time)) %>%
    gt::tab_options(table.width = gt::pct(100)) %>%
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


#' Retrieve Email for Active Content Lead
#'
#' `get_content_lead()` retrieves the email of teh currently assigned content
#' lead. The function retrieves a list of content leads and their assignment
#' dates, checks these against the current date, and returns a character string
#' containing an email address.
#' @param google_drive_auth Authorization token for the SER Google Drive account.
#' @export
get_content_lead <- function(google_drive_auth = drive_auth_token()) {
  googledrive::drive_auth(path = google_drive_auth)

  content_lead_id <- googledrive::drive_find(
    pattern = "content_leads",
    type = "spreadsheet"
  ) %>%
    dplyr::pull(id) %>%
    googledrive::as_id()
  googledrive::drive_download(content_lead_id, type = "csv", overwrite = TRUE)
  content_leads <- readr::read_csv("content_leads.csv")

  lead_email <- content_leads %>%
    dplyr::mutate(current_lead = is_current_lead(start_date, end_date)) %>%
    dplyr::filter(current_lead) %>%
    dplyr::pull(email) %>%
    stringr::str_trim()

  if (lead_email == "") lead_email <- character()

  lead_email
}

is_current_lead <- function(start_date, end_date) {
  scheduled_time <-
    lubridate::interval(lubridate::mdy(start_date), lubridate::mdy(end_date))

  lubridate::today() %within% scheduled_time
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
  authorize_gmailr()

  yesterday <- lubridate::today() - lubridate::days(1)

  ser_tweets <- rtweet::get_timeline("societyforepi", n = 100, token = twitter_token())
  todays_tweets <- ser_tweets %>%
    # set time zone to New York
    dplyr::mutate(
      date = lubridate::ymd_hms(created_at, tz = "UTC") %>% lubridate::with_tz(get_ny_tz()),
      # replace HTML characters with literal characters. May need to use something more general if this
      # gets unweildy in time, e.g. a lookup table or `gt::fmt_markdown()`
      text = stringr::str_replace_all(text, "\\&amp\\;", "\\&"),
      text = stringr::str_replace_all(text, "\\&gt\\;", "\\>"),
      text = stringr::str_replace_all(text, "\\&lt\\;", "\\<")
    ) %>%
    dplyr::filter(lubridate::floor_date(date, "day") == yesterday)

  original_tweets <- todays_tweets %>%
    dplyr::filter(!is_retweet) %>%
    dplyr::mutate(url = paste0("https://www.twitter.com/", screen_name, "/status/", status_id)) %>%
    dplyr::mutate(Time = paste0("[", date, "](", url, ")")) %>%
    dplyr::select(Time, `Tweet Text` = text)

  retweets <- todays_tweets %>%
    dplyr::filter(is_retweet) %>%
    dplyr::mutate(url = paste0("https://www.twitter.com/", screen_name, "/status/", status_id)) %>%
    dplyr::mutate(Time = paste0("[", date, "](", url, ")")) %>%
    dplyr::select(Time, `Retweeted From` = retweet_screen_name, `Retweet Text` = text)

  mention_tweets <- rtweet::get_mentions(token = twitter_token())

  mentions <- mention_tweets %>%
    # only get direct mentions or replies
    dplyr::filter(is.na(in_reply_to_screen_name) | in_reply_to_screen_name == "societyforepi") %>%
    # set time zone to New York
    dplyr::mutate(
      date = lubridate::ymd_hms(created_at, tz = "UTC") %>% lubridate::with_tz(get_ny_tz()),
      text = stringr::str_replace_all(text, "\\&amp\\;", "\\&")
    ) %>%
    dplyr::filter(lubridate::floor_date(date, "day") == yesterday)

  if (!purrr::is_empty(mentions$status_id)) {
    mention_ids <- rtweet::lookup_tweets(mentions$status_id, token = twitter_token())

    mentions <- mentions %>%
      dplyr::left_join(mention_ids %>% dplyr::select(status_id, screen_name), by = "status_id") %>%
      dplyr::filter(screen_name != "societyforepi") %>%
      dplyr::mutate(url = paste0("https://www.twitter.com/", screen_name, "/status/", status_id)) %>%
      dplyr::mutate(Time = paste0("[", date, "](", url, ")")) %>%
      dplyr::select(Time, `Mentioned By` = screen_name, `Tweet Text` = text)
  }

  email_msg <- paste(
    "<h1> Tweets from @societyforepi:",
    yesterday,
    "</h1> \n",
    build_html(original_tweets, "tweets"),
    "\n",
    build_html(retweets, "retweets"),
    "\n",
    build_html(mentions, "mentions")
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

authorize_gmailr <- function() {
  googledrive::drive_auth(path = drive_auth_token())
  googledrive::drive_download(googledrive::as_id("190WyqiP-ogT6NY3PzRSiCafGzylPaoQt"), overwrite = TRUE)
  unzip(".secret.zip")
  gmailr::gm_auth_configure()
  gmailr::gm_auth(email = gmail_email(), cache = ".secret", scopes = "compose")
  zip(".secret.zip", ".secret")
  googledrive::drive_update(googledrive::as_id("190WyqiP-ogT6NY3PzRSiCafGzylPaoQt"), ".secret.zip")
}
