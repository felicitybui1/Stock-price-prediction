library(stringr)
library(tm)
library(SnowballC)
library(NLP)
library(textrank)
library(tidyverse)


library(tidytext)



library(readr)
# enter orginal dataset name here 
f = read.csv('original tweets_stocks.csv')
punctuation <- c(",", ".", "!", "?", ";", ":", "-", "_", "/", "\\", "|", "(", ")", "[", "]", "{", "}", "<", ">", "\"", "'", "`", "~", "@", "#", "$", "%", "^", "&", "*", "+", "=")


clean_tweet <- function(tweet_list, is_bytes = FALSE) {
  # Load required libraries
  library(stringr)
  library(tm)
  
  # Define function to split compound words
  compound_word_split <- function(compound_word) {
    matches <- gregexpr('.+?(?:(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|$)', compound_word, perl = TRUE)
    regmatches(compound_word, matches)[[1]]
  }
  
  # Define function to remove non-ASCII characters
  remove_non_ascii_chars <- function(text) {
    iconv(text, from = "UTF-8", to = "ASCII//TRANSLIT")
  }
  
  # Define function to remove hyperlinks
  remove_hyperlinks <- function(text) {
    gsub("\\bhttps?://\\S+\\b", "", text, perl = TRUE)
  }
  
  # Define stop words and punctuation table
  stop_words <- stopwords("english")
  punc_table <- chartr(punctuation, " ", "")
  
  # Define function to clean a single tweet
  get_cleaned_text <- function(text) {
    cleaned_tweet <- gsub('\"|\'', '', text) %>% 
      remove_non_ascii_chars() %>% 
      remove_hyperlinks() %>% 
      gsub('#', 'HASHTAGSYMBOL', .) %>% 
      gsub('@', 'ATSYMBOL', .) %>% 
      str_split(pattern = "\\s+") %>% 
      unlist() %>% 
      tolower() %>% 
      .[! . %in% stop_words & nchar(.) > 1] %>% 
      sapply(compound_word_split) %>% 
      paste(collapse = " ") %>% 
      gsub('HASHTAGSYMBOL', '#', .) %>% 
      gsub('ATSYMBOL', '@', .)
    return(cleaned_tweet)
  }
  
  # Define function to clean a list of tweets
  if (is_bytes) {
    tweet_list <- sapply(tweet_list, function(x) get_cleaned_text(iconv(x, "UTF-8")))
  } else {
    tweet_list <- sapply(tweet_list, get_cleaned_text)
  }
  
  return(tweet_list)
}


# write the cleaned tweet file here 
tw = clean_tweet(f, is_bytes = FALSE)
f$Tweets = tw
f1 = subset(f, select = -c(ticker_symbol,tweet_id,close_value,volume,open_value,high_value,low_value,body))

stockname = 'AAPL' # ENTER stockname here 
write.csv(f1, file = paste0('tweets1_', stockname, '.csv'), row.names = F)


# this function is used to group all tweets together by day and make a new csv file 

processTweets <- function(stockname) {
  
  columns <- c('Date', 'Tweets')
  data <- data.frame(matrix(nrow = 0, ncol = length(columns)))
  colnames(data) <- columns
  
  df <- read.csv(paste0('tweets_', stockname, '.csv'), header = F, col.names = columns, encoding = 'UTF-8')
  
  
  indx <- 0
  get_tweet <- ""
  
  # get tweets day wise
  for (i in 1:(nrow(df)-1)) {
    get_date <- df$Date[i]
    next_date <- df$Date[i+1]
    if (!is.na(get_date) && !is.na(next_date) && get_date == next_date) {
      
      get_tweet <- paste(get_tweet, df$Tweets[i], sep = " . ")
    }
    if (!is.na(get_date) && !is.na(next_date) && get_date != next_date) {
      
      data[indx, 'Date'] <- get_date
      data[indx, 'Tweets'] <- get_tweet
      indx <- indx + 1
      get_tweet <- " "
    }
  }
  
  
  # save cleaned data to a CSV file
  write.csv(data, file = paste0('processedTweets1_', stockname, '.csv'), row.names = F)
}

# define name of a company to preprocess 
processTweets('AMZN')

library(lexRankr)

##### This algorithm is more accurate than the method we have used for text summarisation however , because of the slow runtime due to cpu/gpu 
#### limitation we cant use it right now in a practical sense. 

lexrank_top4 <- function(text) {
  # Run LexRank algorithm
  top_4 <- lexRank(text,
                   # Only 1 article; repeat same docid for all of input vector
                   docId = rep(1, length(text)),
                   # Return 4 sentences to mimic /u/autotldr's output
                   n = 4,
                   continuous = TRUE)
  
  # Reorder the top 4 sentences to be in order of appearance in article
  order_of_appearance <- order(as.integer(gsub("_", "", top_4$sentenceId)))
  # Extract sentences in order of appearance
  ordered_top_4 <- top_4[order_of_appearance, "sentence"]
  
  # Return the top 3 sentences as a single string
  s <- paste(ordered_top_4, collapse = " ")
  return(s)
}
######################

# we read the processed file we generated in the previous step and create and a subset of tweets after 1st april 2017
d = read.csv('processedTweets1_AMZN.csv')

len = nrow(d)

d_subset = d[(len-1003) : len,]

d$Date[len - 1003]

## over here we summarizes the tweets for each day by selecting the first 5 relevant tweets returned by the tibble function. This is not the most efficient approach 
## however its the only one which works in a reasonable time frame 

summarize_article <- function(article_text) {
 
  article_sentences <- tibble(text = article_text) %>%
    unnest_tokens(sentence, text, token = "sentences") %>%
    mutate(sentence_id = row_number()) %>%
    select(sentence_id, sentence) 
    return(paste0(article_sentences$sentence[1:5], collapse = " "))
}

# we apply the summarize article function to all the tweets here and drop the old tweets column to reduce the load on storage 
data_summ = function(df) {
  df$summ_text = ""
  for (i in 1 :nrow(df)){
    df$summ_text[i] = summarize_article(df$Tweets[i])
  }
  
  df1 = subset(df, select = -c(Tweets) )
  
  return (df1)
}

# we call the summarization function
summ_data = data_summ(d_subset)


# we use vader lib for the sentiment analysis on the summarized tweets 
library(vader)

sentimentAnalysis <- function(df) {
  data = df
  data$Comp <- ""
  data$Negative <- ""
  data$Neutral <- ""
  data$Positive <- ""
  for (i in 1:nrow(data)) {
      sentence_sentiment <- get_vader(data$summ_text[i])
      data$Comp[i] <- sentence_sentiment['compound']
      data$Negative[i] <- sentence_sentiment['neg']
      data$Neutral[i] <- sentence_sentiment['neu']
      data$Positive[i] <- sentence_sentiment['pos']
  }
  data <- data[, !grepl("Unnamed", names(data))] # remove unnamed column
  data = subset(data, select = -c(summ_text))
  write.csv(data, file = paste0("sentimentAnalysis2_", 'MSFT', ".csv"), row.names = FALSE)
  # change name of company here depending the file u want to generate 
  
}


sentimentAnalysis(summ_data)



















