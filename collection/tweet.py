#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

# referred by http://tweepy.readthedocs.org/en/v2.3.0/

import tweepy

consumer_key = '< INPUT >'
consumer_secret = '< INPUT >'

access_token = '< INPUT >'
access_token_secret = '< INPUT >'

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth)

# old method : Limit 100
# search_tweets = api.search(q='안철수',count=100)
# for tweet in search_tweets:
#     print tweet.text

# cursor method
cnt = 0
for tweet in tweepy.Cursor(api.search,
                           q="안철수",
                           count=10,
                           result_type="recent",
                           include_entities=True,
                           lang="ko").items(25):
	cnt += 1
	print (tweet.text)

print cnt
