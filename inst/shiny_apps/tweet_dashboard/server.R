#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(rtweet)
library(ser)
library(plotly)
library(ggplot2)
library(dplyr)
library(forcats)
library(lubridate)
library(rlang)

ser_mentions <- readr::read_rds(file.path("data", "ser_mentions.Rds"))
mentioners <- readr::read_rds(file.path("data", "mentioners.Rds"))
ser_tweets <- readr::read_rds(file.path("data", "ser_tweets.Rds"))
n_followers <- readr::read_rds(file.path("data", "n_followers.Rds"))

theme_minimal_v <- function() {
    list(
        theme_minimal(14),
        theme(
            panel.grid.minor = element_blank(),
            panel.grid.major.y = element_blank()
        )
    )
}

theme_minimal_h <- function() {
    list(
        theme_minimal(14),
        theme(
            panel.grid.minor = element_blank(),
            panel.grid.major.x = element_blank()
        )
    )
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  from_date <- reactive({
      if (input$timerange == "NA") return(NA)
      add_with_rollback(today(), -days(input$timerange)) %>%
          as.Date()
  })


  mentions_since <- reactive({
      if (is.na(from_date())) return(ser_mentions)
      ser_mentions %>%
          filter(created_at >= from_date())
  })

  mentioners_since <- reactive({
      if (is.na(from_date())) return(mentioners)
      mentioners %>%
          filter(created_at >= from_date())
  })

  tweets_since <- reactive({
      if (is.na(from_date())) return(filter(ser_tweets, !is_retweet))
      ser_tweets %>%
          filter(created_at >= from_date(), !is_retweet)
  })

  n_followers_since <- reactive({
      if (is.na(from_date())) return(n_followers)
      n_followers %>%
          filter(date >= from_date())
  })

  x_date_lim <- reactive({
      if (is.na(from_date())) return(list())
      list(
          xlim(
              as_datetime(today() - days(input$timerange)),
              as_datetime(today())
          )
      )
  })

  output$n_tweets <- renderInfoBox({
    infoBox("Tweets", value = nrow(tweets_since()), fill = TRUE, icon = icon("twitter"), color = "yellow")
  })

  output$n_mentions <- renderInfoBox({
    infoBox("Mentions", value = nrow(mentions_since()), fill = TRUE, icon = icon("bullhorn"), color = "yellow")
  })


  output$n_mentioners <- renderInfoBox({
      infoBox("Unique Mentioners", value = n_distinct(mentioners_since()$user_id), fill = TRUE, icon = icon("users"), color = "yellow")
  })


  output$most_liked <- renderInfoBox({
    n_likes <- sum(tweets_since()$favorite_count, na.rm = TRUE)
    infoBox("Likes", value = n_likes, fill = TRUE, icon = icon("heart"), color = "yellow")
  })

  output$most_retweeted <- renderInfoBox({
    n_retweets<- sum(tweets_since()$retweet_count, na.rm = TRUE)
    infoBox("Retweets", value = n_retweets, fill = TRUE, icon = icon("retweet"), color = "yellow")
  })

  output$n_followers <- renderInfoBox({
    infoBox("Followers", value = n_followers_since()$n_followers[nrow(n_followers_since())], fill = TRUE, icon = icon("keyboard"), color = "yellow")
  })

  output$n_tweets_plot <- renderPlotly({
     n_tweets_plot <- tweets_since() %>%
      ts_plot(color = "#0172B1", size = .8) +
      x_date_lim() +
      theme_minimal_v()

     ggplotly(n_tweets_plot)
  })

  output$most_x_plot <- renderPlotly({
    most_x <- sym(input$most_x)

    most_x_plot <- tweets_since() %>%
      arrange(desc(!!most_x)) %>%
      head(100) %>%
      arrange(!!most_x) %>%
      mutate(text = stringr::str_wrap(text), status_id = fct_inorder(status_id)) %>%
      ggplot(aes_string("status_id", input$most_x, text = "text")) +
      geom_point(col = "white", fill = "#0072B2", shape = 21, size = 2.2) +
      theme_minimal_h() +
      theme(axis.text.x = element_blank()) +
      labs(x = "tweet", y = ifelse(input$most_x == "favorite_count", "favorites", "retweets"))

    ggplotly(most_x_plot, tooltip = c("text", "y"))
  })

  output$mentions_plot <- renderPlotly({
    mentions_plot <- mentions_since() %>%
      ts_plot(color = "#0172B1", size = .8) +
      theme_minimal_v() +
      x_date_lim()

    ggplotly(mentions_plot)
  })

  output$top_mentions_plot <- renderPlotly({
   top_mentions_plot <- mentioners_since() %>%
      count(screen_name) %>%
      arrange(desc(n)) %>%
      head(18) %>%
      mutate(
          screen_name = paste0("@", screen_name),
          screen_name = fct_rev(fct_inorder(screen_name))
      ) %>%
      ggplot(aes(screen_name, n)) +
      geom_col(col = "white", fill = "#0072B2") +
      coord_flip() +
      theme_minimal_v() +
      theme(
        axis.title.y = element_blank(),
        axis.text.y = element_text(hjust = 1)
      ) +
      ylab("mentions")

      ggplotly(top_mentions_plot)
  })

  output$n_followers_plot <- renderPlotly({
      n_followers_plot <- n_followers_since() %>%
          mutate(date = lubridate::as_datetime(date), n_followers = as.integer(n_followers)) %>%
          ggplot(aes(date, n_followers)) +
          geom_line(col = "#0072B2") +
          geom_point(col = "white", fill = "#0072B2", shape = 21, size = 2.2) +
          theme_minimal_v() +
          theme(
              axis.title.y = element_blank(),
              axis.text.y = element_text(hjust = 1)
          ) +
          ylab("n followers") +
          xlab("date") +
          scale_y_continuous(breaks = function(x) floor(scales::breaks_pretty()(x))) +
          x_date_lim()

      ggplotly(n_followers_plot)
  })



  output$top_liked <- renderUI({
      status_id <- tweets_since() %>%
          arrange(desc(favorite_count)) %>%
          slice(1) %>%
          pull(status_id)

      embed_tweet(status_id)
  })

  output$top_retweeted <- renderUI({
      status_id <- tweets_since() %>%
          arrange(desc(retweet_count)) %>%
          slice(1) %>%
          pull(status_id)

      embed_tweet(status_id)
  })
})
