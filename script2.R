# first load blogs data
# open file for reading
blogs.file <- file("data/final/en_US/en_US.blogs.txt", "r")
# read the content while ignoring the NULLs
blogs.lines <- readLines(blogs.file, encoding = "UTF-8", skipNul = TRUE, warn = FALSE)
# close file
close(blogs.file)
# get rid of un-used variable
rm(blogs.file)

#next load news data
# open file for reading
news.file <- file("data/final/en_US/en_US.news.txt", "r")
# read the content while ignoring the NULLs
news.lines <- readLines(news.file, encoding = "UTF-8", skipNul = TRUE, warn = FALSE)
# close file
close(news.file)
# get rid of un-used variable
rm(news.file)

# finally load twitter data
# open file for reading
twitter.file <- file("data/final/en_US/en_US.twitter.txt", "r")
# read the content while ignoring the NULLs
twitter.lines <- readLines(twitter.file, encoding = "UTF-8", skipNul = TRUE, warn = FALSE)
# close file
close(twitter.file)
# get rid of un-used variable
rm(twitter.file)


###################################

# no sampling attempt

###################################

all.lines <- c(blogs.lines, news.lines, twitter.lines)

rm(blogs.lines)
rm(news.lines)
rm(twitter.lines)

require(quanteda)

corp <- corpus(all.lines)
toks <- tokens(corp,
               remove_punct = TRUE,
               remove_symbols = TRUE,
               remove_numbers = TRUE,
               remove_url = TRUE,
               remove_separators = TRUE,
               split_hyphens = TRUE)

rm(all.lines)

