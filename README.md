
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
content leads, daily email summaries of Twitter activity on the SER
account, and posts tweets related to the annual meeting during the three
months prior.

  - `action_auto_tweet()`
  - `action_email_summary()`
  - `action_meeting_tweet()`

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

## Getting access to the Twitter API

You’ll need access to the SER Twitter account. Log in and go to
<https://developer.twitter.com/en/apps>. There, you will find four items
you need: the consumer key, consumer secret, access token, and access
secret. ser has a function called `ser_token()` that provides a way to
access the SER tokens. To do so, you’ll need to put them in your
.Renviron file. Use the usethis package to open it.

``` r
# if you need to install usethis
# install.packages("usethis")

# Open your .Renviron file
usethis::edit_r_environ()
```

There, you’ll need to add the SER tokens. Here, I’ve put in fake digits.
Replace them with the real tokens.

``` r
SER_CONSUMER_KEY=1i2345y6789a
SER_CONSUMER_SECRET=12345d6789b
SER_ACCESS_TOKEN=1g2345678c
SER_ACCESS_SECRET=123r4567f89d
```

Save and restart. Many of the functions in rtweet have a `token`
argument. Call `ser_token()` to gain access to the Twitter API:

``` r
rtweet::get_mentions(token = ser_token())
```
