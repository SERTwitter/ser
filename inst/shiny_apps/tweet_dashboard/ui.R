#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(
    dashboardPage(
        dashboardHeader(title = "SER Twitter Activity"),
        dashboardSidebar(
            selectInput("timerange", "Time Range", choices = c("30 days" = 30L, "90 days" = 90L, "1 Year" = 365L, "Ever" = NA)),
            sidebarMenu(
                menuItem("SER Tweets", tabName = "tweets_tab", icon = icon("twitter")),
                menuItem("Mentions", tabName = "mentions_tab", icon = icon("bullhorn")),
                menuItem("Followers", tabName = "followers_tab", icon = icon("users")),
                tags$br(),
                tags$br(),
                tags$p("Note: mentions and follower data only collected since 12/21/2019. Mention data covers the most recent 200 mentions prior to that time.", style = "white-space:normal;padding-left: 20px;")
            )
        ),
        dashboardBody(
            tabItems(
                tabItem(
                    tabName = "tweets_tab",
                    fluidRow(
                        infoBoxOutput("n_tweets"),
                        infoBoxOutput("most_liked"),
                        infoBoxOutput("most_retweeted")
                    ),
                    fluidRow(
                        box(withSpinner(plotlyOutput("n_tweets_plot")), title = "Tweets from SER"),
                        box(
                            withSpinner(plotlyOutput("most_x_plot")),
                            selectInput("most_x", "Sort by", choices = c("Favorites" = "favorite_count", "Retweets" = "retweet_count")),
                            title = "Top 100 Tweets"
                        )
                    ),
                    fluidRow(
                        box(withSpinner(uiOutput("top_liked")), title = "Most Favorited SER Tweet"),
                        box(withSpinner(uiOutput("top_retweeted")), title = "Most Retweeted SER Tweet")
                    )
                ),
                tabItem(
                    tabName = "mentions_tab",
                    fluidRow(
                        infoBoxOutput("n_mentions"),
                        infoBoxOutput("n_mentioners")
                    ),
                    fluidRow(
                        box(withSpinner(plotlyOutput("mentions_plot")), title = "Mentions of @societyforepi"),
                        box(withSpinner(plotlyOutput("top_mentions_plot")), title = "Most Frequent Mentioners")
                    )
                ),
                tabItem(
                    tabName = "followers_tab",
                    fluidRow(
                        infoBoxOutput("n_followers")
                    ),
                    fluidRow(
                        box(withSpinner(plotlyOutput("n_followers_plot")), title = "Number of followers")
                    )
                )
            )
        )
    )
)
