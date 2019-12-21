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
library(plotly)

# Define UI for application that draws a histogram
shinyUI(
    dashboardPage(
        dashboardHeader(title = "SER Twitter Activity"),
        dashboardSidebar(
            selectInput("timerange", "Time Range", choices = c("30 days" = 30L, "90 days" = 90L, "1 Year" = 365L, "Ever" = 1e6L)),
            sidebarMenu(
                menuItem("SER Tweets", tabName = "tweets_tab", icon = icon("twitter")),
                menuItem("Mentions", tabName = "mentions_tab", icon = icon("bullhorn")),
                menuItem("Followers", tabName = "followers_tab", icon = icon("users"))
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
                        box(plotlyOutput("n_tweets_plot"), title = "Tweets from SER"),
                        box(plotlyOutput("most_x_plot"), title = "Tweets by **Likes/Retweetes**")
                    ),
                    fluidRow(
                        box(uiOutput("top_liked"), title = "Most Liked SER Tweet"),
                        box(uiOutput("top_retweeted"), title = "Most Retweeted SER Tweet")
                    )
                ),
                tabItem(
                    tabName = "mentions_tab",
                    fluidRow(
                        infoBoxOutput("n_mentions"),
                        infoBoxOutput("n_mentioners")
                    ),
                    fluidRow(
                        box(plotlyOutput("mentions_plot"), title = "Mentions of @societyforepi"),
                        box(plotlyOutput("top_mentions_plot"), title = "Most Frequent Mentioners")
                    ),
                ),
                tabItem(
                    tabName = "followers_tab",
                    fluidRow(
                        infoBoxOutput("n_followers")
                    )
                )
            )
        )
    )
)
