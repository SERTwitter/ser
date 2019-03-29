.email_to <- new.env(parent = emptyenv())

#' @export
#' @rdname errors
on_error_email_to <- function(recipient) {
  .email_to$email <- recipient
  invisible(recipient)
}

#' @export
#' @rdname errors
email_to <- function() {
  .email_to$email
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
email_on_error <- function(.e, gmail_secret_file = "client_id.json", recipient = email_to()) {
  gmailr::use_secret_file(gmail_secret_file)

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
