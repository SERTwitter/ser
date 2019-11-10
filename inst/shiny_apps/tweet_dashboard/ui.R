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

# Define UI for application that draws a histogram
shinyUI(
    dashboardPage(
        dashboardHeader(title = "SER Twitter Activity"),
        dashboardSidebar(
            selectInput("timerange", "Time Range", choices = c("30 days" = 30L, "90 days" = 90L, "1 Year" = 365L))
        ),
        dashboardBody(
            fluidRow(
                infoBoxOutput("n_tweets"),
                infoBoxOutput("n_mentions"),
                infoBoxOutput("most_liked"),
                infoBoxOutput("most_retweeted")
            )
        )
    )
)
