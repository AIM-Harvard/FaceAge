# -----------------
# Script for plotting Kaplan-Meier curves of survey-takers' Performance
# predicting 6-month survival of palliative patients
# -----------------

# The code and data of this repository are intended to promote transparent and reproducible research
# of the paper "Decoding biological age from face photographs using deep learning"

# All the details about the project can be found at the following webpage:
# aim.hms.harvard.edu/FaceAge

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# AIM 2022

# import libraries/dependencies
import numpy as np
from numpy import load
from numpy import isnan
from pandas import read_csv
from pandas import DataFrame as DF
from matplotlib import pyplot as plt
from datetime import datetime
from lifelines import KaplanMeierFitter
from lifelines.statistics import logrank_test
from lifelines.utils import concordance_index as CI

# set significance level
alpha = 0.05

# survival observation time in years (-1 = all time)
T = 2

# specify the embedding version of inception-resnet v1 CNN
rootpath = './'
inputpath = 'survey_part1_results.csv'


# load master processed file
data = read_csv(rootpath + inputpath)

# instantiate Kaplan-Meier survival fitting function
kmf = KaplanMeierFitter()

# select survey taker survival predictions to analyze
varnameA = 'S2 surv'
varnameB = varnameA

# get age and survival time data
varA = data[varnameA]
varB = data[varnameB]
survival_time = data['survival time']
event_flag = data['event flag']

# right censor events beyond observation window
if T > 0:
    event_flag[survival_time > T] = 0

# define survival categories by predicted alive (>0) or not (=0) at 6 months
cat_A = 'varA > 0'
cat_B = 'varB == 0'

# Compute survival results and plot actuarial survival curves using Kaplan-Meier approach
ax = plt.subplot(111)

# Category A (predicted alive at 6 months)
kmf.fit(survival_time[eval(cat_A)],
        event_observed=event_flag[eval(cat_A)], label="Predicted >= 6 mo")
kmf_age_gap_lower = kmf.median_survival_time_
kmf.plot(ax = ax, ci_show = False, show_censors = False)

# Category B (predicted survival < 6 months)
kmf.fit(survival_time[eval(cat_B)],
        event_observed=event_flag[eval(cat_B)], label="Predicted < 6 mo")
kmf_age_gap_upper = kmf.median_survival_time_
kmf.plot(ax = ax, ci_show = False, show_censors = False)

# perform logrank test evaluating whether statistical difference in survival curves
results = logrank_test(survival_time[eval(cat_A)],
                        survival_time[eval(cat_B)],
                        event_flag[eval(cat_A)],
                        event_flag[eval(cat_B)], alpha = alpha, t_0 = T)

# print to screen summary of results
print('Results for Performance \n')
print('Median survival ( <= 1): %.2f' % kmf_age_gap_lower)
print('Median survival ( > 1): %.2f \n' % kmf_age_gap_upper)
results.print_summary()
print('\n')

# plot the KM curves for the given observation window
if T > -1:
    plt.xlim((0,T))
plt.show()
