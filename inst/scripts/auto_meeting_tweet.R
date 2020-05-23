library(ser)

on_error_email_to(c(gmail("malcolmbarrett"), email("jason_gantenberg", "brown.edu")))
safe_action_meeting_tweet <- action_safely(action_meeting_tweet, "(auto_meeting_tweet.R)")
safe_action_meeting_tweet()
