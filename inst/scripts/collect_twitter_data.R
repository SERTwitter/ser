library(ser)
library(rtweet)
options(gargle_oob_default = TRUE)
options(gargle_oauth_email = gmail("ser.twitteracct"))

on_error_email_to(c(gmail("malcolmbarrett"), email("jason_gantenberg", "brown.edu")))
safely_collect_twitter_data <- action_safely(action_collect_twitter_data, "(collect_twitter_data.R)")
safely_collect_twitter_data()
