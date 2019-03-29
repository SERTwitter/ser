.email_to <- new.env(parent = emptyenv())

#' @export
#' @rdname errors
on_error_email_to <- function(recipient, gmail_id, gmail_secret) {
  .email_to$email <- recipient
  .email_to$gmail_id <- gmail_id
  .email_to$gmail_secret <- gmail_secret
  invisible(c(recipient, gmail_id, gmail_secret))
}

#' @export
#' @rdname errors
email_to <- function() {
  .email_to$email
}

#' @export
#' @rdname errors
gmail_id <- function() {
  .email_to$gmail_id
}

#' @export
#' @rdname errors
gmail_secret <- function() {
  .email_to$gmail_secret
}


build_error_html <- function(.error) {
  paste("<h2>Error in SER code:", Sys.time(), "</h2> \n", .error)
}

#' Email errors in code
#'
#' `email_on_error()` will email on error. Use it with `action_safely()` to wrap
#' a function using the emailer. Set the email recipient globally with
#' `on_error_email_to()` and retrieve it with `email_to()`.
#'
#' @param .e the error message
#' @param gmail_secret_file the name of the gmail authorization file
#' @param recipient an email address.
#'
#' @return a character vector containing the error email
#' @export
#'
#' @rdname errors
email_on_error <- function(.e, recipient = email_to()) {
  gmailr::gmail_auth("compose", id = gmail_id(), secret = gmail_secret())

  email_msg <- build_error_html(.e)

  gmailr::mime() %>%
    gmailr::to(recipient) %>%
    gmailr::from("ser.twitteracct@gmail.com") %>%
    gmailr::subject(paste("Error in SER code:", Sys.time())) %>%
    gmailr::html_body(email_msg) %>%
    gmailr::send_message()

  invisible(email_msg)
}

#' @export
#' @rdname errors
action_safely <- function(.f) {
  function(...) {
    tryCatch(
      .f(...),
      error = email_on_error
    )
  }
}
