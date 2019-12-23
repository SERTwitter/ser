embed_tweet <- function(id) {
  url <- paste0("https://publish.twitter.com/oembed?url=https://twitter.com/Interior/status/", id)
  tweet <- htmltools::HTML(jsonlite::fromJSON(url)$html)

  class(tweet) <- c("tweet", class(tweet))
  tweet
}

print.tweet <- function(x, ...) {
  htmltools::html_print(x)
  invisible(x)
}
