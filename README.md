# STOCK PRICE TWEET SENTIMENT AND NEURAL NETWORKS

The stock market is one of the most widely studied subjects with numerous participants in research from top financial firms to academia aiming to understand not only how to make accurate predictions but to understand its behavior. Its movements are influenced by various internal and external factors such as political and legal events, economic cycles, and even social media trends. With the rise of social media platforms providing greater transparency, velocity, and exchange of information, it is now easier than ever for financial market participants to follow and analyze the market and individual stock.

## Project Overview

In this project, I applied sentiment analysis using a statistical machine learning model and random forest in an attempt to capture the correlation between the tweets extracted from Twitter and stock’s price market movements. My exploration sought to answer the following research question:

**How would daily stock prices behave in response to a positive, neutral, or negative sentiment scoring of tweets related to the respective stock?**

## Data Sources

### Tweets about the Top Companies from 2015 to 2020 via Kaggle
- This dataset is utilized for extracting tweets mentioning Amazon, Apple, Google, Microsoft, and Tesla, by employing their relevant share tickers.

### Yahoo Finance
- The data of stock prices for Apple, Google, Amazon, Tesla, and Microsoft was obtained for the time period of 2015-2020.

## Discussion of the Data

For the project, I used two main sets of data, one is the tweets data about Apple, Google, Amazon, Tesla, and Microsoft from 2015 to 2020 and the other is stock price data of those companies also during the period of 2015 to 2020. Instead of using all the data, I only used 1000-day-period data from April 2014 to 2020.

### Twitter Dataset (Tweet.csv)
- **Tweet_id:** Tweet’s ID given by Twitter
- **Writer:** Account name of the tweet’s author
- **Post_date:** post date in form seconds since epoch
- **Body:** text of tweet
- **Comment_num:** number of comments on tweet
- **Retweet_num:** number of retweet 
- **Like_num:** number of like on tweet

### Company's Tweet Dataset (Company_Tweet.csv)
- **Tweet_id:** unique tweet’s ID given by Twitter
- **Ticker_symbol:** company’s stock ticker

### Stock Price Dataset
- **Date:** Date
- **Close value:** Stock price closing value 
- **Adjusted close value:** Stock price adjusted closing value 
- **Open value:** Stock price open value 
- **High value:** Stock price high value 
- **Low value:** Stock price low value 
- **Volume:** Trading volume of stock

## Data Preparation and Preprocessing

In terms of the analytical methods used in this assignment, I had a few important decisions to make and plan the whole process. The first step was pre-processing the tweets file for the company of choice. This means removing all special characters, hyperlinks, ASCII characters, stopwords, punctuations, replacing some particular symbols, removing ads and lowercasing all the text to maintain consistency.

After cleaning the tweets, I grouped tweets together by day over the last few years available in the dataset; the purpose is to match the adjusted closing price for each date with the sentiment. Moreover, rather than finding the sentiment of each individual tweet, which is not very accurate or relevant to my greater objective, I find the overall sentiment of all the tweets made on a particular day of the year.

## Limitations and Opportunity for Further Exploration

Before deciding to pursue this subject of exploration, the limitations was how to interpret the results of any study done with the relationship between tweets and stock price. Particularly looking at the relationship between tweets and stock behavior, the chicken or the egg problem emerges, whether the tweets cause stock behavior, or an external event indirectly fluctuated the frequency of tweets about a stock for which its behavior is immediately reflecting.

## Discussion of Findings

Among my findings, specifically, as I explored the sentiment analysis conducted, there tends to be a more significant proportion of neutral tweets about stocks. Considering the tweet volume shared among our focus group of stocks, this could suggest that the nature of discussion surrounding a stock on Twitter is mainly informational as opposed to persuasive or reciprocal of any external events that may influence sentiment. While we extrapolate the aggregate of specific content in tweets posted during the observation period–as to whether they are factual–this information exchange provides the basis for influence on daily trading activities of financial market participants.

Since my prediction model only factors in the proportions of sentiments for testing our hypothesis, stock price predictions heavily reflect the trends presented in the sentiment analysis. Without any data manipulation, I found that the sentiment alone cannot predict stock prices perfectly.
