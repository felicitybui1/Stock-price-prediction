library(caret)
library(magrittr)
library(dplyr)
library(lattice)
library(mice)
library(caTools)
library(aod)
library(ISLR2)
library(mgcv)
library(MASS)
library(leaps)
library(xgboost)
library(rpart)
library(ggplot2)
library(tidyr)
library(skimr)
library(ROCR)
library(rpart.plot)
library(Metrics)
library(ipred)
library(ranger)
library(gbm)
library(e1071)
library(stringr)
library(readr)
library(forcats)
library(mgcv)
library(tm)
library(SnowballC)

file1  = read.csv('tweets_stocks.csv')

#create corpus vector
corpus = Corpus(VectorSource(file1$body))

#lowercase
corpus = tm_map(corpus,FUN = content_transformer(tolower))

#remove urls
corpus = tm_map(corpus,
                FUN = content_transformer(FUN = function(x)gsub(pattern = 'http[[:alnum:][:punct:]]*',
                                                                replacement = ' ',x = x)))

#remove special chars and punctuation
corpus = tm_map(corpus,FUN = removePunctuation)

#remove whitespace and stem document 
corpus = tm_map(corpus,FUN = stripWhitespace)
corpus = tm_map(corpus,FUN = stemDocument)
corpus$content

# code to convert corpus to dataframe and extract it 

df1 = data.frame(text = sapply(corpus, as.character), stringsAsFactors = FALSE)
write.csv(df1 , 'corpusFinal.csv')

### This part is not related to the preprocessing directly and is more related to tokenisation and creating dictionaries 
## however still mentioning the rough code here on what more we may do with data before the training process. 
#create document matrix
dtm = DocumentTermMatrix(corpus)
dtm

#remove sparse terms 
xdtm = removeSparseTerms(dtm,sparse = 0.95)
xdtm

#create dictionary from original data
dict = findFreqTerms(DocumentTermMatrix(Corpus(VectorSource(file1))),
                     lowfreq = 0)
dict_corpus = Corpus(VectorSource(dict))

#unstem the words back to their original form 

xdtm = as.data.frame(as.matrix(xdtm))
colnames(xdtm) = stemCompletion(x = colnames(xdtm),
                                dictionary = dict_corpus,
                                type='prevalent')
colnames(xdtm) = make.names(colnames(xdtm))

#view the terms 
sort(colSums(xdtm),decreasing = T)
















