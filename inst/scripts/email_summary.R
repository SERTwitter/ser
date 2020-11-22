library(ser)

on_error_email_to(c(gmail("malcolmbarrett"), email("jason_gantenberg", "brown.edu")))
safe_action_email_summary <- action_safely(action_email_summary)
send_summary_to <- c(
  gmail("malcolmbarrett"),
  email("Anusha.Vable", "ucsf.edu"),
  email("sbevan", "epiresearch.org"),
  email("mumfords", "mail.nih.gov"),
  email("Magdalena.Cerda", "nyulangone.org"),
  email("jason_gantenberg", "brown.edu"),
  email("mkiang", "stanford.edu"),
  get_content_lead()
)

safe_action_email_summary(recipients = send_summary_to)
