library(ser)
setwd(file.path("/home", "rstudio", "Dropbox", "rstudio_server", "ser_twitter"))
# if need to restart port
# sudo lsof -i :1410
# kill -9 [PID from list]
# options(httr_oob_default = TRUE)


on_error_email_to(c(gmail("malcolmbarrett"), email("jason_gantenberg", "brown.edu")))
safe_action_email_summary <- action_safely(action_email_summary)
send_summary_to <- c(
  gmail("malcolmbarrett"),
  email("Anusha.Vable", "ucsf.edu"),
  email("sbevan", "epiresearch.org"),
  email("mumfords", "mail.nih.gov"),
  email("Magdalena.Cerda", "nyulangone.org"),
  email("jason_gantenberg", "brown.edu"),
  email("mkiang", "stanford.edu")
)

safe_action_email_summary(recipients = send_summary_to)
