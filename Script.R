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

set.seed(1234)
# take a random sample of data (10,000 lines per source)
sample.lines <- c(sample(blogs.lines, 10000),
                  sample(news.lines, 10000),
                  sample(twitter.lines, 10000))
# free-up the memory
rm(blogs.lines)
rm(news.lines)
rm(twitter.lines)
gc()

# clean-up non-ASCII characters
sample.lines <- iconv(sample.lines, to = "ASCII", sub = "")
# get rid of http/ftp/etc...
sample.lines <- gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", sample.lines)
# get rid of @...
sample.lines <- gsub("@[^\\s]+", "", sample.lines)

library(tm)
# create corpus
corpus <- VCorpus(VectorSource(sample.lines))
# clean the corpus
corpus <- tm_map(corpus, tolower)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeWords, stopwords("english"))
corpus <- tm_map(corpus, PlainTextDocument)
# tokenize
library(RWeka)
# define tokenizer helper functions
uniTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 1, max = 1))
biTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
triTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
quadTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 4, max = 4))
# tokenize
unigrams <- TermDocumentMatrix(corpus, control = list(tokenize = uniTokenizer))
bigrams <- TermDocumentMatrix(corpus, control = list(tokenize = biTokenizer))
trigrams <- TermDocumentMatrix(corpus, control = list(tokenize = triTokenizer))
quadgrams <- TermDocumentMatrix(corpus, control = list(tokenize = quadTokenizer))

# get frequencies with low threshold of 100 to control the object size
helper <- sort(rowSums(as.matrix(unigrams[findFreqTerms(unigrams, lowfreq = 100),])), decreasing = TRUE)
uniFreqs <- data.frame(unigram=names(helper), frequency = helper)
helper <- sort(rowSums(as.matrix(bigrams[findFreqTerms(bigrams, lowfreq = 100),])), decreasing = TRUE)
biFreqs <- data.frame(bigram=names(helper), frequency = helper)
helper <- sort(rowSums(as.matrix(trigrams[findFreqTerms(trigrams, lowfreq = 10),])), decreasing = TRUE)
triFreqs <- data.frame(trigram=names(helper), frequency = helper)
helper <- sort(rowSums(as.matrix(quadgrams[findFreqTerms(quadgrams, lowfreq = 2),])), decreasing = TRUE)
quadFreqs <- data.frame(quadgram=names(helper), frequency = helper)
rm(helper)

library(ggplot2)
ggplot(uniFreqs[1:20,], aes(x = reorder(unigram, frequency), y = frequency)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Top 20 uni-grams") +
  xlab("")

ggplot(biFreqs, aes(x = reorder(bigram, frequency), y = frequency)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Top bi-grams") +
  xlab("")

ggplot(triFreqs, aes(x = reorder(trigram, frequency), y = frequency)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Top tri-grams") +
  xlab("")

