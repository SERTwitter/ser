library(ser)
library(rtweet)
options(gargle_oob_default = TRUE)
options(gargle_oauth_email = gmail("ser.twitteracct"))

on_error_email_to(c(gmail("malcolmbarrett"), email("jason_gantenberg", "brown.edu")))
safely_deploy_dashboard <- action_safely(action_deploy_dashboard)
safely_deploy_dashboard()
