"""
决策树
"""

import pandas as pd
import numpy as np
from script.utils import get_input_data, PatientAttr
from sklearn.tree import DecisionTreeRegressor, export_graphviz
import graphviz
import matplotlib.pyplot as plt


source_data = get_input_data()
source_data = source_data.fillna(-1)

# regressor = DecisionTreeRegressor(random_state=0)
# patient_attr = PatientAttr(source_data)
# regressor.fit(patient_attr.data, patient_attr.target)
# dot_data = export_graphviz(regressor, out_file=None,
#                            feature_names=patient_attr.feature_names,
#                            filled=True, rounded=True,
#                            special_characters=True)

graph = graphviz.Source(dot_data)
graph.render('test.gv', view=True)

total_amount = pd.Series(source_data['总金额'])
total_amount = total_amount[total_amount.map(lambda x: x != -1)]
total_amount = total_amount[total_amount.map(lambda x: x != 0)]

bins = np.linspace(total_amount.min(), 10, 1000).tolist()
pd.cut(total_amount, bins).value_counts().plot()
plt.show()