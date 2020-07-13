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

require(quanteda)

corp <- corpus(all.lines)

rm(all.lines)

toks <- tokens(corp,
               remove_punct = TRUE,
               remove_symbols = TRUE,
               remove_numbers = TRUE,
               remove_url = TRUE,
               remove_separators = TRUE,
               split_hyphens = TRUE)

# toks_nostop <- tokens_select(toks, pattern = stopwords('en'), selection = 'remove')


# toks_l <- tokens_tolower(toks_nostop)
toks_l <- tokens_tolower(toks)

rm(toks)
#rm(toks_nostop)

toks_2gram <- tokens_ngrams(toks_l, n = 2, concatenator = " ")

dfmat2 <- dfm(toks_2gram)
dfmat2_min2 <- dfm_trim(dfmat2, min_termfreq = 2)
dfmat2Freq2plus <- colSums(dfmat2_min2)

rm(dfmat2)
rm(toks_2gram)

toks_3gram <- tokens_ngrams(toks_l, n = 3, concatenator = " ")

dfmat3 <- dfm(toks_3gram)
dfmat3_min2 <- dfm_trim(dfmat3, min_termfreq = 2)
dfmat3Freq2plus <- colSums(dfmat3_min2)

rm(dfmat3)
rm(toks_3gram)

toks_4gram <- tokens_ngrams(toks_l, n = 4, concatenator = " ")

dfmat4 <- dfm(toks_4gram)
dfmat4_min2 <- dfm_trim(dfmat4, min_termfreq = 2)
dfmat4Freq2plus <- colSums(dfmat4_min2)

rm(dfmat4)
rm(toks_4gram)

toks_5gram <- tokens_ngrams(toks_l, n = 5, concatenator = " ")

dfmat5 <- dfm(toks_5gram)
dfmat5_min2 <- dfm_trim(dfmat5, min_termfreq = 2)
dfmat5Freq2plus <- colSums(dfmat5_min2)

rm(dfmat5)
rm(toks_5gram)

rm(dfmat2_min2)
rm(dfmat3_min2)
rm(dfmat4_min2)
rm(dfmat5_min2)
gc()

d2gramF <- sort(dfmat2Freq2plus, decreasing = TRUE)
d3gramF <- sort(dfmat3Freq2plus, decreasing = TRUE)
d4gramF <- sort(dfmat4Freq2plus, decreasing = TRUE)
d5gramF <- sort(dfmat5Freq2plus, decreasing = TRUE)

require(data.table)

freq.2gram <- data.table(ngram = names(d2gramF), frequency = d2gramF)
freq.3gram <- data.table(ngram = names(d3gramF), frequency = d3gramF)
freq.4gram <- data.table(ngram = names(d4gramF), frequency = d4gramF)
freq.5gram <- data.table(ngram = names(d5gramF), frequency = d5gramF)

rm(d2gramF)
rm(d3gramF)
rm(d4gramF)
rm(d5gramF)
rm(dfmat2Freq2plus)
rm(dfmat3Freq2plus)
rm(dfmat4Freq2plus)
rm(dfmat5Freq2plus)

freq.2gram[, c("key", "value") := tstrsplit(ngram, " ", fixed = TRUE)]
freq.3gram[, c("key1", "key2", "value") := tstrsplit(ngram, " ", fixed = TRUE)]
freq.4gram[, c("key1", "key2", "key3", "value") := tstrsplit(ngram, " ", fixed = TRUE)]
freq.5gram[, c("key1", "key2", "key3", "key4", "value") := tstrsplit(ngram, " ", fixed = TRUE)]

freq.3gram[, "key" := paste(key1, key2)]
freq.4gram[, "key" := paste(key1, key2, key3)]
freq.5gram[, "key" := paste(key1, key2, key3, key4)]

freq.3gram[, c("key1", "key2"):=NULL]
freq.4gram[, c("key1", "key2", "key3"):=NULL]
freq.5gram[, c("key1", "key2", "key3", "key4"):=NULL]

setcolorder(freq.3gram, c("ngram","frequency","key","value"))
setcolorder(freq.4gram, c("ngram","frequency","key","value"))
setcolorder(freq.5gram, c("ngram","frequency","key","value"))
tables()

setkey(freq.2gram, key)
setkey(freq.3gram, key)
setkey(freq.4gram, key)
setkey(freq.5gram, key)

mylist <- list(freq.2gram, freq.3gram, freq.4gram,freq.5gram)

db <- rbindlist(mylist, use.names = TRUE)
rm(mylist)

db[,"ngram":=NULL]

setkey(db, key)
# get rid of duplicate entries, as we need only the first one...
db1 <- db[!duplicated(key),]
fwrite(db1, compress = "gzip", file = "data/db1.csv.gz")

rm(freq.2gram)
rm(freq.3gram)
rm(freq.4gram)
rm(freq.5gram)
rm(db)
rm(toks_l)


