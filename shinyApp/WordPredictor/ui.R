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
            helpText("Please, enter some text in the field below. It will be cleaned,
            tokenized and analyzed using N-grams prediction model with backoff.
            A most-likely word to follow (based on the class provided training data)
            will be returned."),
            hr(),
            textInput("inputString", "Here goes your text", value = "", ),
            submitButton("Submit"),
            helpText("The user interface of this app is intentionally simplistic.
            The emphasis of the class capstone project was on learning and efficiently
            implementing natural language processing techniques (with possible real-life
            application) rather than developing a fancy toy with tons of \"bells and whistles\".")
        ),
        # Show a plot of the generated distribution
        mainPanel(
            h3("The text you've entered:"),
            verbatimTextOutput("text1"),
            hr(),
            h3("Predicted word:"),
            verbatimTextOutput("prediction"),
            helpText("The word above is an output of the \"Katz's back-off\" generative n-gram
            language model. The model generated for this application was optimized for size and
            efficiency. 5-grams, 4-grams and 3-grams have been selected with frequencies of 2
            and above. Any duplicates between these consecutively applied models have been
            eliminated. Once loaded in the application memory, the model occupies 201MB. The size
            of a model file distributed with the application is approximately 13.7MB."),
            hr(),
            code(textOutput("text2"))
        )
    )
))