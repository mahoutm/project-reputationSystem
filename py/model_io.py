from sklearn import svm
from sklearn import datasets

clf = svm.SVC()
iris = datasets.load_iris()
X, y = iris.data, iris.target
clf.fit(X, y)  
print clf.predict(X[0])

#import pickle
#s = pickle.dumps(clf)
#clf2 = pickle.loads(s)
#print clf2.predict(X[0])
#
from sklearn.externals import joblib
joblib.dump(clf, 'egg.pkl')
# clf = joblib.load('egg.pkl') 
