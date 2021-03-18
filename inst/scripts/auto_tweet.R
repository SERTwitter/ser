library(ser)

# if deauthorized on google drive:
# googledrive::drive_auth(use_oob = TRUE)
options(gargle_oob_default = TRUE)
options(gargle_oauth_email = gmail("ser.twitteracct"))

on_error_email_to(c(gmail("malcolmbarrett"), email("jason_gantenberg", "brown.edu")))
safe_action_auto_tweet <- action_safely(action_auto_tweet)
safe_action_auto_tweet()
