# -----------------
# Script for computing ROC/AUC of survey-takers' Performance predicting age and 6-month survival correspondence of palliative patients
# with and without FaceAge augmentation
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

import pandas as pd
import numpy as np
from sklearn import metrics
from lifelines.utils import concordance_index
import sys

# inputs
path = './'
db_age = 'survey_p1_age_out.csv'
db_surv = 'survey_p1_6mo_surv_out.csv'
ref_file = 'Palliative-Survey.csv'

# initialize dataframes
df_age = pd.read_csv(path + db_age)
df_surv = pd.read_csv(path + db_surv)
df_age_out = pd.DataFrame()
df_surv_out = pd.DataFrame()

# set number of columns (= number of survey takers)
Ncolumns = 10

# survival time threhold (fraction of year -> 6 months)
theta = 0.5

# compute performance metrics
def performance(Y,Yref):
    Ncorrect = np.sum(Y == Yref)
    acc = Ncorrect/len(Y)
    over = np.sum(Y > Yref)/len(Y)
    under = np.sum(Y < Yref)/len(Y)
    return under, acc, over

# compute pooled performance metrics
def pooledperf(df, Ncolumns, chrono_ref):
    Sval = []
    chrono = []
    Ncorrect = []
    Nover = []
    Nunder = []
    Ntotal = Ncolumns*len(df)
    for k in range(Ncolumns):
        delta = df['S'+str(k+1)].values - chrono_ref
        Ncorrect.append(np.sum(delta == 0))
        Nover.append(np.sum(delta > 0))
        Nunder.append(np.sum(delta < 0))
    acc = np.sum(Ncorrect)/Ntotal
    over = np.sum(Nover)/Ntotal
    under = np.sum(Nunder)/Ntotal
    return under, acc, over


# compute ROC, AUC and C-index
def rocci(Ypred,Y,E):
    fpr, tpr, thresholds = metrics.roc_curve(Y[E>0], Ypred[E>0])
    roc_auc = metrics.auc(fpr, tpr)
    acc = metrics.accuracy_score(Y[E>0],Ypred[E>0])
    ci = concordance_index(Y, Ypred, E)
    return fpr,tpr,roc_auc,ci

# define columns for dataframe
columns = ['S1',
           'S2',
           'S3',
           'S4',
           'S5',
           'S6',
           'S7',
           'S8',
           'S9',
           'S10',
           'Pooled',
           'Face Age']

# convert to integer binned values (per decade) as recorded in survey
fa_age = np.floor(df_age['face age'].values / 10)
chrono_age_floor = np.floor(df_age['chronologic age'].values / 10)

# compute age prediction performance of humans and face age
S1_age = performance(df_age['S1'],chrono_age_floor)
S2_age = performance(df_age['S2'],chrono_age_floor)
S3_age = performance(df_age['S3'],chrono_age_floor)
S4_age = performance(df_age['S4'],chrono_age_floor)
S5_age = performance(df_age['S5'],chrono_age_floor)
S6_age = performance(df_age['S6'],chrono_age_floor)
S7_age = performance(df_age['S7'],chrono_age_floor)
S8_age = performance(df_age['S8'],chrono_age_floor)
S9_age = performance(df_age['S9'],chrono_age_floor)
S10_age = performance(df_age['S10'],chrono_age_floor)
FA_age = performance(fa_age,chrono_age_floor)
Pooled_age = pooledperf(df_age,Ncolumns,chrono_age_floor)

# add to dataframe
df_age_out['S1'] = S1_age
df_age_out['S2'] = S2_age
df_age_out['S3'] = S3_age
df_age_out['S4'] = S4_age
df_age_out['S5'] = S5_age
df_age_out['S6'] = S6_age
df_age_out['S7'] = S7_age
df_age_out['S8'] = S8_age
df_age_out['S9'] = S9_age
df_age_out['S10'] = S10_age
df_age_out['Pooled'] = Pooled_age
df_age_out['Face Age'] = FA_age

# write to file
df_age_out.to_csv('survey_part1_age_results.csv', index = None)


# compute 6 mo survival prediction performance of humans and face age
S1_roc = rocci(df_surv['S1 surv'],df_surv['Actual Survival'],df_surv['event flag'])
S2_roc = rocci(df_surv['S2 surv'],df_surv['Actual Survival'],df_surv['event flag'])
S3_roc = rocci(df_surv['S3 surv'],df_surv['Actual Survival'],df_surv['event flag'])
S4_roc = rocci(df_surv['S4 surv'],df_surv['Actual Survival'],df_surv['event flag'])
S5_roc = rocci(df_surv['S5 surv'],df_surv['Actual Survival'],df_surv['event flag'])
S6_roc = rocci(df_surv['S6 surv'],df_surv['Actual Survival'],df_surv['event flag'])
S7_roc = rocci(df_surv['S7 surv'],df_surv['Actual Survival'],df_surv['event flag'])
S8_roc = rocci(df_surv['S8 surv'],df_surv['Actual Survival'],df_surv['event flag'])
S9_roc = rocci(df_surv['S9 surv'],df_surv['Actual Survival'],df_surv['event flag'])
S10_roc = rocci(df_surv['S10 surv'],df_surv['Actual Survival'],df_surv['event flag'])
PRED_roc = rocci(df_surv['Predicted Survival'],df_surv['Actual Survival'],df_surv['event flag'])
val = df_surv['CPH uni T = 0.5 years']
PRED_uni_roc = rocci(val > theta, df_surv['Actual Survival'],df_surv['event flag'])

# add to dataframe
df_surv_out['S1 surv'] = S1_roc
df_surv_out['S2 surv'] = S2_roc
df_surv_out['S3 surv'] = S3_roc
df_surv_out['S4 surv'] = S4_roc
df_surv_out['S5 surv'] = S5_roc
df_surv_out['S6 surv'] = S6_roc
df_surv_out['S7 surv'] = S7_roc
df_surv_out['S8 surv'] = S8_roc
df_surv_out['S9 surv'] = S9_roc
df_surv_out['S10 surv'] = S10_roc
df_surv_out['Predicted Survival'] = PRED_roc
df_surv_out['Predicted Survival (uni)'] = PRED_uni_roc

# compute survival correspondence of age estimates from humans, face age and chrono age
S1_roc = rocci(df_surv['S1 age'],df_surv['Actual Survival'],df_surv['event flag'])
S2_roc = rocci(df_surv['S2 age'],df_surv['Actual Survival'],df_surv['event flag'])
S3_roc = rocci(df_surv['S3 age'],df_surv['Actual Survival'],df_surv['event flag'])
S4_roc = rocci(df_surv['S4 age'],df_surv['Actual Survival'],df_surv['event flag'])
S5_roc = rocci(df_surv['S5 age'],df_surv['Actual Survival'],df_surv['event flag'])
S6_roc = rocci(df_surv['S6 age'],df_surv['Actual Survival'],df_surv['event flag'])
S7_roc = rocci(df_surv['S7 age'],df_surv['Actual Survival'],df_surv['event flag'])
S8_roc = rocci(df_surv['S8 age'],df_surv['Actual Survival'],df_surv['event flag'])
S9_roc = rocci(df_surv['S9 age'],df_surv['Actual Survival'],df_surv['event flag'])
S10_roc = rocci(df_surv['S10 age'],df_surv['Actual Survival'],df_surv['event flag'])
FA_roc = rocci(df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])
CA_roc = rocci(df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])

# add to dataframe
df_surv_out['S1 age'] = S1_roc
df_surv_out['S2 age'] = S2_roc
df_surv_out['S3 age'] = S3_roc
df_surv_out['S4 age'] = S4_roc
df_surv_out['S5 age'] = S5_roc
df_surv_out['S6 age'] = S6_roc
df_surv_out['S7 age'] = S7_roc
df_surv_out['S8 age'] = S8_roc
df_surv_out['S9 age'] = S9_roc
df_surv_out['S10 age'] = S10_roc
df_surv_out['face age'] = FA_roc
df_surv_out['chrono age'] = CA_roc

# compute survival correspondence of age estimates from humans with chrono age added
S1_roc = rocci(df_surv['S1 age']+df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S2_roc = rocci(df_surv['S2 age']+df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S3_roc = rocci(df_surv['S3 age']+df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S4_roc = rocci(df_surv['S4 age']+df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S5_roc = rocci(df_surv['S5 age']+df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S6_roc = rocci(df_surv['S6 age']+df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S7_roc = rocci(df_surv['S7 age']+df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S8_roc = rocci(df_surv['S8 age']+df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S9_roc = rocci(df_surv['S9 age']+df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S10_roc = rocci(df_surv['S10 age']+df_surv['chrono age decade'],df_surv['Actual Survival'],df_surv['event flag'])

# add to dataframe
df_surv_out['S1 age+chrono'] = S1_roc
df_surv_out['S2 age+chrono'] = S2_roc
df_surv_out['S3 age+chrono'] = S3_roc
df_surv_out['S4 age+chrono'] = S4_roc
df_surv_out['S5 age+chrono'] = S5_roc
df_surv_out['S6 age+chrono'] = S6_roc
df_surv_out['S7 age+chrono'] = S7_roc
df_surv_out['S8 age+chrono'] = S8_roc
df_surv_out['S9 age+chrono'] = S9_roc
df_surv_out['S10 age+chrono'] = S10_roc

# compute survival correspondence of age estimates from humans with face age added
S1_roc = rocci(df_surv['S1 age']+df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S2_roc = rocci(df_surv['S2 age']+df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S3_roc = rocci(df_surv['S3 age']+df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S4_roc = rocci(df_surv['S4 age']+df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S5_roc = rocci(df_surv['S5 age']+df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S6_roc = rocci(df_surv['S6 age']+df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S7_roc = rocci(df_surv['S7 age']+df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S8_roc = rocci(df_surv['S8 age']+df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S9_roc = rocci(df_surv['S9 age']+df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])
S10_roc = rocci(df_surv['S10 age']+df_surv['face age decade'],df_surv['Actual Survival'],df_surv['event flag'])

# add to dataframe
df_surv_out['S1 age+FA'] = S1_roc
df_surv_out['S2 age+FA'] = S2_roc
df_surv_out['S3 age+FA'] = S3_roc
df_surv_out['S4 age+FA'] = S4_roc
df_surv_out['S5 age+FA'] = S5_roc
df_surv_out['S6 age+FA'] = S6_roc
df_surv_out['S7 age+FA'] = S7_roc
df_surv_out['S8 age+FA'] = S8_roc
df_surv_out['S9 age+FA'] = S9_roc
df_surv_out['S10 age+FA'] = S10_roc

# write results to file
df_surv_out.to_csv('survey_part1_results.csv', index = None)
