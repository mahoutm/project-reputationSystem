# loading sample data.
import csv
import numpy as np

lx = []
with open('reputation_sample.csv', 'rb') as cf:
	doc = csv.reader(cf, delimiter=',')
	for row in doc:
		lx.append(row)

ax = np.array(lx)
