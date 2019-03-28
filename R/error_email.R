email_on_error <- function(.e) {

}

action_safley <- function(.f) {
  function() {
    tryCatch(
      .f
    )
  }
}
