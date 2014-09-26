#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import tweepy

consumer_key = 'WX5khpDKiMqUfBSey6jE1HIIB'
consumer_secret = '3siy2tRZRJzH2mgdZ5gj0ntEAo7dejkjCdKik62VAAeC5QYT7S'

access_token = '2599333584-EHejq2qadhVt8p40THkLjvqHy69xzbqaxgeE0rr'
access_token_secret = 'UyR3gqG1NFPZLzaXl0Qtt8PExTRGUdulKa3Tw3vrCoAmo'

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth)

# public_tweets = api.home_timeline()
search_tweets = api.search(q='안철수')
for tweet in search_tweets:
    print tweet.text
