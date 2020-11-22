
library(ser)
# if deauthorized on google drive:
# googledrive::drive_auth(use_oob = TRUE)
options(gargle_oob_default = TRUE)
options(gargle_oauth_email = gmail("ser.twitteracct"))

library(rtweet)

#  -------------------------------------------------------------------------

on_error_email_to(c(gmail("malcolmbarrett"), gmail("jason.gantenberg")))
# if testing post_tweet_of_type manually on a weekend, set todays_date to a weekday
# in action_auto_tweet() below
safe_action_auto_tweet <- action_safely(
  action_auto_tweet(
    todays_date = "Mon",
    twitter_token = sandbox_token()
  )
)

safe_action_auto_tweet(twitter_token = sandbox_token())

