embed_tweet <- function(id) {
  # url <- paste0("https://publish.twitter.com/oembed?url=https://twitter.com/Interior/status/", id)
  # tweet <- htmltools::HTML(jsonlite::fromJSON(url)$html)

  tweet <- htmltools::HTML(get_tweet_blockquote("societyforepi", id))

  class(tweet) <- c("tweet", class(tweet))
  tweet
}

#' @importFrom htmltools html_print
#' @export
print.tweet <- function(x, ...) {
  htmltools::html_print(x)
  invisible(x)
}


get_tweet_blockquote <- function(screen_name, status_id, ..., null_on_error = TRUE, theme = "light") {
  oembed <- list(...)$oembed
  if (!is.null(oembed) && !is.na(oembed)) return(unlist(oembed))
  oembed_url <- glue::glue("https://publish.twitter.com/oembed?url=https://twitter.com/{screen_name}/status/{status_id}&omit_script=1&dnt=1&theme={theme}")
  bq <- purrr::possibly(httr::GET, list(status_code = 999))(URLencode(oembed_url))
  if (bq$status_code >= 400) {
    if (null_on_error) return(NULL)
    '<blockquote style="font-size: 90%">Sorry, unable to get tweet ¯\\_(ツ)_/¯</blockquote>'
  } else {
    httr::content(bq, "parsed")$html
  }
}
