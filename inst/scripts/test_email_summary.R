library(ser)
# setwd(file.path("/home", "rstudio", "Dropbox", "rstudio_server", "ser_twitter"))
# if need to restart port
# sudo lsof -i :1410
# kill -9 [PID from list]
# options(httr_oob_default = TRUE)

on_error_email_to(c(gmail("malcolmbarrett"), gmail("jason.gantenberg")))
safe_action_email_summary <- action_safely(action_email_summary)
send_summary_to <- c(gmail("malcolmbarrett"), gmail("jason.gantenberg"))

safe_action_email_summary(recipients = send_summary_to)
