library(ser)
setwd(file.path("/home", "rstudio", "Dropbox", "rstudio_server", "ser_twitter"))

on_error_email_to(c(gmail("malcolmbarrett"), email("jason_gantenberg", "brown.edu")))
safe_action_meeting_tweet <- action_safely(action_meeting_tweet)
safe_action_meeting_tweet()
