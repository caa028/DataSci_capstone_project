
library(data.table)
db <- fread("db.csv.gz")
tables()
setkey(db, key)
library(tm)
library(stringr)

processInput <- function(input_string) {
  # clean-up the input string
  buffer_string <- iconv(input_string, to = "ASCII", sub = "")
  buffer_string <- str_to_lower(buffer_string)
  buffer_string <- removePunctuation(buffer_string,
                                     preserve_intra_word_dashes = TRUE)
  buffer_string <- removeNumbers(buffer_string)
  buffer_string <- stripWhitespace(buffer_string)
  strsplit(buffer_string, "\\s")[[1]]
}

predictWord <- function(input_list) {
  # decide what to do according to the number of words available
  if (length(input_list) >= 4) {
    input_list <- tail(input_list, 4)
    message(">>\t searching for 5-gram match")
    prediction <- db[paste(unlist(input_list), collapse = " "), value]
    if (!is.na(prediction)) {
      message("+\t found a match:\n\t",
              db[paste(unlist(input_list), collapse = " ")])
      return(prediction)
      }
    message("-\t match not found, switching to 4-gram")
    input_list <- tail(input_list, 3)
  }
  if (length(input_list) == 3) {
    message(">>\t searching for 4-gram match")
    prediction <- db[paste(unlist(input_list), collapse = " "), value]
    if (!is.na(prediction)) {
      message("+\t found a match:\n\t",
              db[paste(unlist(input_list), collapse = " ")])
      return(prediction)
    }
    message("-\t match not found, switching to 3-gram")
    input_list <- tail(input_list, 2)
  }
  if (length(input_list) == 2) {
    message(">>\t searching for 3-gram match")
    prediction <- db[paste(unlist(input_list), collapse = " "), value]
    if (!is.na(prediction)) {
      message("+\t found a match:\n\t",
              db[paste(unlist(input_list), collapse = " ")])
      return(prediction)
    }
    message("-\t match not found, switching to 2-gram")
    input_list <- tail(input_list, 1)
  }
  message(">>\t searching for 2-gram match")
  prediction <- db[paste(unlist(input_list), collapse = " "), value]
  if (!is.na(prediction)) {
    message("+\t found a match:\n\t",
            db[paste(unlist(input_list), collapse = " ")])
    return(prediction)
  } else {
    message("!\t no matches found, returning a guess")
    return("guess")
  }
}

predictWord1 <- function(input_list) {
  # we are not prepared to go deeper than 5-gram
  if (length(input_list) > 4) {
    input_list <- tail(input_list, 4)
  }
  while (length(input_list) > 0) {
    # execute back-off algorithm
    message(">> searching for ", length(input_list) + 1, "-gram match")
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
      return(prediction)
    }
    # back-off
    input_list <- tail(input_list, length(input_list) - 1)
  }
  # oops - no match in the model
  message("!\t no matches found, returning a guess")
  return("guess")
}
