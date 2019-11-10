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


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    output$n_tweets <- renderInfoBox({
        infoBox("Tweets", value = NA, fill = TRUE, icon = icon("twitter"), color = "yellow", width = 3)
    })

    output$n_mentions <- renderInfoBox({
        infoBox("Mentions", value = NA, fill = TRUE, icon = icon("bullhorn"), color = "yellow", width = 3)
    })

    output$most_liked <- renderInfoBox({
        infoBox("Likes", value = NA, fill = TRUE, icon = icon("heart"), color = "yellow", width = 3)
    })

    output$most_retweeted <- renderInfoBox({
        infoBox("Retweets", value = NA, fill = TRUE, icon = icon("retweet"), color = "yellow", width = 3)
    })

})
