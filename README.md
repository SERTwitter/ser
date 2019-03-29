
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ser

The goal of ser is to automate parts of the SER Communications Committee
workflow (e.g. posting to Twitter). This package makes it easier to do
so reproducibly and in a place where it is easier for us to collaborate
on new automated workflows.

## Installation

You can install the package off of GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("SERTwitter/ser")
```

## What does ser currently do?

ser handles automatic daily tweeting to supplement the work done by
content leads and daily email summaries of Twitter activity on the SER
account.

  - `action_auto_tweet()`
  - `action_email_summary()`

ser also provides functions to email summaries of errors that may occur
in code while running automatically on the server. `action_safely()`
wraps functions to catch errors and email them to an address set by
`on_error_email_to()`

``` r
library(ser)
on_error_email_to("your@email.com")

auto_error <- function() {
  stop("this code stopped working")
}

safe_auto_error <- action_safely(auto_error)

# sends an email to stored email address with error message
safe_auto_error()
```
