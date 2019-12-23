library(ser)
library(rtweet)
options(gargle_oob_default = TRUE)
options(gargle_oauth_email = gmail("ser.twitteracct"))

on_error_email_to(gmail("malcolmbarrett"))
safely_deploy_dashboard <- action_safely(action_deploy_dashboard)
safely_deploy_dashboard()
