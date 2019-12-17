library(ser)
auto_error <- function() {
  stop("this is a test as well")
}
on_error_email_to(gmail("malcolmbarrett"))
safe_auto_error <- action_safely(auto_error)
safe_auto_error()
