#
# Coursera/JHU Data Science Course
# Capstone Project: Word Predictor Shiny App
# July 2020
# Anatoly Andrianov
#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
# Define UI for application that draws a histogram
shinyUI(fluidPage(
    # Application title
    titlePanel("Coursera/JHU Data Science Course - Capstone Project"),
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            helpText("Please, enter some text. It will be analyzed using N-grams
                     prediction model with backoff. A most-likely word to follow
                     (based on SwiftKey dataset) will be returned."),
            hr(),
            textInput("inputString", "Here goes your text", value = "", ),
            submitButton("Submit")
        ),
        # Show a plot of the generated distribution
        mainPanel(
            h3("The text you've entered:"),
            verbatimTextOutput("text1"),
            hr(),
            h3("Predicted word:"),
            verbatimTextOutput("prediction"),
            hr(),
            code(textOutput("text2"))
        )
    )
))