library(ser)

on_error_email_to(c(gmail("malcolmbarrett"), email("jason_gantenberg", "brown.edu")))
safe_action_email_summary <- action_safely(action_email_summary, "(email_summary.R)")
send_summary_to <- c(
  gmail("malcolmbarrett"),
  email("sbevan", "epiresearch.org"),
  email("mumfords", "mail.nih.gov"),
  email("Magdalena.Cerda", "nyulangone.org"),
  email("jason_gantenberg", "brown.edu"),
  email("mkiang", "stanford.edu")
)

safe_action_email_summary(recipients = send_summary_to)
