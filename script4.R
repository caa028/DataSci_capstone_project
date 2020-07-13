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

all.lines <- c(blogs.lines, news.lines, twitter.lines)

rm(blogs.lines)
rm(news.lines)
rm(twitter.lines)

all.lines <- iconv(all.lines, to = "ASCII", sub = "")
all.lines <- gsub("_", " ", all.lines)

require(quanteda)
require(data.table)

corp <- corpus(all.lines)

rm(all.lines)

toks <- tokens(corp,
               remove_punct = TRUE,
               remove_symbols = TRUE,
               remove_numbers = TRUE,
               remove_url = TRUE,
               remove_separators = TRUE)

rm(corp)

# toks_nostop <- tokens_select(toks, pattern = stopwords('en'), selection = 'remove')

toks <- tokens_select(toks, "#.*", selection = "remove", valuetype = "regex")
toks <- tokens_select(toks, "@.*", selection = "remove", valuetype = "regex")
toks <- tokens_select(toks, "-.*", selection = "remove", valuetype = "regex")
toks <- tokens_select(toks, "\\d.*", selection = "remove", valuetype = "regex")
toks <- tokens_select(toks, ".*\\..*", selection = "remove", valuetype = "regex")
toks <- tokens_select(toks, ".*:.*", selection = "remove", valuetype = "regex")
toks <- tokens_select(toks, ".*(.)\\1{2,}.*", selection = "remove", valuetype = "regex")
toks <- tokens_select(toks, "^(.)\\1{1,}.*", selection = "remove", valuetype = "regex")
toks <- tokens_tolower(toks)
toks <- tokens_select(toks, "^[b-hj-z]$", selection = "remove", valuetype = "regex")
toks <- tokens_select(toks, "^[ab-hj-z]'.*$", selection = "remove", valuetype = "regex")

# 2-grams
toks_2gram <- tokens_ngrams(toks, n = 2, concatenator = " ")

dfmat2 <- dfm(toks_2gram)
dfmat2Freq <- colSums(dfmat2)

rm(dfmat2)
rm(toks_2gram)
gc()
d2gramF <- sort(dfmat2Freq, decreasing = TRUE)
freq.2gram <- data.table(ngram = names(d2gramF), frequency = d2gramF)
rm(d2gramF)
rm(dfmat2Freq)
freq.2gram[, c("key", "value") := tstrsplit(ngram, " ", fixed = TRUE)]
setcolorder(freq.2gram, c("ngram","key","value","frequency"))
freq.2gram[, "ngram":=NULL]
freq.2gram <- freq.2gram[!duplicated(key),]
fwrite(freq.2gram, compress = "gzip", file = "data/freq.2gram.csv.gz")

tables()

# 3-grams
toks_3gram <- tokens_ngrams(toks, n = 3, concatenator = " ")

dfmat3 <- dfm(toks_3gram)
dfmat3Freq <- colSums(dfmat3)

rm(dfmat3)
rm(toks_3gram)
gc()
d3gramF <- sort(dfmat3Freq, decreasing = TRUE)
freq.3gram <- data.table(ngram = names(d3gramF), frequency = d3gramF)
rm(d3gramF)
rm(dfmat3Freq)
gc()
freq.3gram[, c("key1", "key", "value") := tstrsplit(ngram, " ", fixed = TRUE)]

# eliminate the entries in 3-gram table that give same answers as 2-gram
freq.3gram <- freq.3gram[!freq.2gram, on = .(key, value)]

# prepare for writing 
freq.3gram[, "key" := paste(key1, key)]
freq.3gram <- freq.3gram[!duplicated(key),]
freq.3gram[, c("ngram", "key1"):=NULL]
setcolorder(freq.3gram, c("key","value","frequency"))

fwrite(freq.3gram, compress = "gzip", file = "data/freq.3gram.csv.gz")

tables()

# 4-grams
toks_4gram <- tokens_ngrams(toks, n = 4, concatenator = " ")

dfmat4 <- dfm(toks_4gram)
dfmat4Freq <- colSums(dfmat4)

rm(dfmat4)
rm(toks_4gram)
d4gramF <- sort(dfmat4Freq, decreasing = TRUE)
freq.4gram <- data.table(ngram = names(d4gramF), frequency = d4gramF)
rm(d4gramF)
rm(dfmat4Freq)
gc()
freq.4gram[, c("key2", "key1", "key", "value") := tstrsplit(ngram, " ", fixed = TRUE)]
# eliminate the entries in 4-gram table that give same answers as 2-gram
freq.4gram <- freq.4gram[!freq.2gram, on = .(key, value)]

# eliminate the entries in 4-gram table that give same answers as 3-gram
freq.4gram[, "key" := paste(key1, key)]
freq.4gram <- freq.4gram[!freq.3gram, on = .(key, value)]

freq.4gram[, "key" := paste(key2, key)]
freq.4gram[, c("ngram", "key1", "key2"):=NULL]
setcolorder(freq.4gram, c("key","value","frequency"))
freq.4gram <- freq.4gram[!duplicated(key),]
fwrite(freq.4gram, compress = "gzip", file = "data/freq.4gram.csv.gz")

tables()

# 5-grams
toks_5gram <- tokens_ngrams(toks, n = 5, concatenator = " ")

dfmat5 <- dfm(toks_5gram)
dfmat5 <- dfm_trim(dfmat5, min_termfreq = 2)
dfmat5Freq <- colSums(dfmat5)

rm(dfmat5)
rm(toks_5gram)
gc()
d5gramF <- sort(dfmat5Freq, decreasing = TRUE)
freq.5gram <- data.table(ngram = names(d5gramF), frequency = d5gramF)
rm(d5gramF)
rm(dfmat5Freq)
gc()
freq.5gram[, c("key3", "key2", "key1", "key", "value") := tstrsplit(ngram, " ", fixed = TRUE)]
# eliminate the entries in 5-gram table that give same answers as 2-gram
freq.5gram <- freq.5gram[!freq.2gram, on = .(key, value)]

# eliminate the entries in 5-gram table that give same answers as 3-gram
freq.5gram[, "key" := paste(key1, key)]
freq.5gram <- freq.5gram[!freq.3gram, on = .(key, value)]

# eliminate the entries in 5-gram table that give same answers as 4-gram
freq.5gram[, "key" := paste(key2, key)]
freq.5gram <- freq.5gram[!freq.4gram, on = .(key, value)]

freq.5gram[, "key" := paste(key3, key)]
freq.5gram[, c("ngram", "key1", "key2", "key3"):=NULL]

setcolorder(freq.5gram, c("key","value","frequency"))
freq.5gram <- freq.5gram[!duplicated(key),]
fwrite(freq.5gram, compress = "gzip", file = "data/freq.5gram.csv.gz")

tables()

freq.3gram <- freq.3gram[frequency != 1]
freq.4gram <- freq.4gram[frequency != 1]
freq.5gram <- freq.5gram[frequency != 1]

mylist <- list(freq.2gram, freq.3gram, freq.4gram,freq.5gram)
db <- rbindlist(mylist, use.names = TRUE)
rm(mylist)

setkey(db, key)

fwrite(db, compress = "gzip", file = "data/db.csv.gz")

rm(freq.2gram)
rm(freq.3gram)
rm(freq.4gram)
rm(freq.5gram)
rm(toks)


