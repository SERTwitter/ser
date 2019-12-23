library(ser)
library(rtweet)
options(gargle_oob_default = TRUE)
options(gargle_oauth_email = gmail("ser.twitteracct"))

on_error_email_to(gmail("malcolmbarrett"))
safely_collect_twitter_data <- action_safely(action_collect_twitter_data)
safely_collect_twitter_data()
