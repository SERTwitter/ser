library(ser)
# if deauthorized on google drive:
# googledrive::drive_auth(use_oob = TRUE)
options(gargle_oob_default = TRUE)
options(gargle_oauth_email = gmail("ser.twitteracct"))

# rtweet hack to fix length check bug -------------------------------------
# TODO: Remove when patched in rtweet (https://github.com/mkearney/rtweet/pull/330)
library(rtweet)

is_tweet_length <- function(.x, n = 280) {
  .x <- gsub("https?://[[:graph:]]+\\s?", "", .x)
  while (grepl("^@\\S+\\s+", .x)) {
    .x <- sub("^@\\S+\\s+", "", .x)
  }
  !(nchar(.x) <= n)   # here's the fix
}
#  ------------------------------------- -----------------------------------

assignInNamespace("is_tweet_length", is_tweet_length, ns = "rtweet")

on_error_email_to(c(gmail("malcolmbarrett")))
safe_action_auto_tweet <- action_safely(action_auto_tweet(twitter_token = sandbox_token()))
safe_action_auto_tweet()
