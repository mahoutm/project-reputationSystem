import numpy as np
import matplotlib.pyplot as plt
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LogisticRegression

#x = mgrid[1:20:20j]
#y = cos(x) % 2

x = array([[1,2,3],[1.1,2,3],[0,4,5],[0,5,5]])
y = array([1,1,0,0])
polynomial_features = PolynomialFeatures(degree=1,include_bias=False)
logistic_regression = LogisticRegression()
pipeline = Pipeline([("polynomial_features", polynomial_features), ("logisic_regression", logistic_regression)])
pipeline.fit(x[:, np.newaxis], y)
scatter(x, y, color='red',s=10,alpha=.5)
#x = mgrid[1:25:25j]
x = array([10,100,300])
pipeline.predict(x)
