# without display
import matplotlib
# matplotlib.use('TkAgg') for displaying on Centos
matplotlib.use('Agg')

# body
import numpy as np
import matplotlib.pyplot as plt
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression

x = np.mgrid[1:24:50j]
y = np.cos(x) + np.log((x*x))
polynomial_features = PolynomialFeatures(degree=3,include_bias=False)
linear_regression = LinearRegression()
pipeline = Pipeline([("polynomial_features", polynomial_features), ("linear_regression", linear_regression)])
pipeline.fit(x[:, np.newaxis], y)

plt.figure(111)
plt.clf()
plt.scatter(x, y, color='red',s=10,alpha=.5)
x = np.mgrid[1:26:50j]
plt.plot(x,pipeline.predict(x[:,np.newaxis]),color='blue',linewidth=5,alpha=.5,linestyle='--')
plt.savefig('result.png')
# plt.show()

