utils::globalVariables(
  c(
    "created_at",
    "desc",
    "favorite_count",
    "head",
    "id",
    "is_retweet",
    "meeting_tweet_queue",
    "retweet_count",
    "retweet_queue",
    "retweet_screen_name",
    "status_id",
    "text",
    "tweet_queue",
    "tweeted"
  )
)


#' Compose email addresses
#'
#' A set of functions to compose email addresses in public scripts to avoid
#' scraping by bots. `gmail()` is a wrapper around `email()` that always appends
#' the gmail domain.
#'
#' @param x the usernname
#' @param y the domain name
#'
#' @export
email <- function(x, y) {
  paste0(x, "@", y)
}

#' @export
#' @rdname email
gmail <- function(x) {
  email(x, "gmail.com")
}
