#
# Coursera/JHU Data Science Course
# Capstone Project: Word Predictor Shiny App
# July 2020
# Anatoly Andrianov
#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
# load required libraries
library(data.table)
library(tm)
library(stringr)

# load the prediction model
message <- "Loading prediction model"

db <- fread("db.csv.gz")
setkey(db, key)

message <- "Prediction model loaded"

predictWord <- function(input_list) {
    # we are not prepared to go deeper than 5-gram
    if (length(input_list) > 4) {
        input_list <- tail(input_list, 4)
    }
    message <- "> "
    while (length(input_list) > 0) {
        # execute back-off algorithm
        message(">> searching for ", length(input_list) + 1, "-gram match")
        message <<- paste(">> searching for ", length(input_list) + 1, "-gram match ")
        # perform model look-up
        prediction <- db[paste(unlist(input_list), collapse = " "), value]
        if (!is.na(prediction)) {
            message("\t+ found a match:\n\t\t\"",
                    db[paste(unlist(input_list), collapse = " "), key],
                    "\" -> \"",
                    db[paste(unlist(input_list), collapse = " "), value],
                    "\" with frequency: ",
                    db[paste(unlist(input_list), collapse = " "), frequency]
            )
            message <<- paste(message, "\t+ found a match:",
                    db[paste(unlist(input_list), collapse = " "), key],
                    " -> ",
                    db[paste(unlist(input_list), collapse = " "), value],
                    " with frequency: ",
                    db[paste(unlist(input_list), collapse = " "), frequency]
            )
            return(prediction)
        }
        # back-off
        input_list <- tail(input_list, length(input_list) - 1)
    }
    # oops - no match in the model
    message("!\t no matches found, returning a guess")
    message <<- paste(message, "! no matches found, returning a guess")
    return("guess")
}



# Define server logic
shinyServer(function(input, output) {

    processInput <- reactive({
        input_string <- input$inputString
        # clean-up the input string
        buffer_string <- iconv(input_string, to = "ASCII", sub = "")
        buffer_string <- str_to_lower(buffer_string)
        buffer_string <- removePunctuation(buffer_string,
                                           preserve_intra_word_dashes = TRUE)
        buffer_string <- removeNumbers(buffer_string)
        buffer_string <- stripWhitespace(buffer_string)
        strsplit(buffer_string, "\\s")[[1]]
    })
    
    output$prediction <- renderText({
        prediction <- predictWord(processInput())
        output$text2 <- renderText({message})
        as.character(prediction)
    })
    
    output$text1 <- renderText({
        input$inputString
    })

})
