# -----------------
# Script for computing ROC/AUC of survey-takers' Performance predicting 6-month survival of palliative patients
# with no clinical aid, with clinical info and with FaceAge risk model compared to FaceAge alone
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
db_surv6mo = 'survey_part1_results.csv'
db_survprob = 'survey_part2_survprob.csv'
db_survmod = 'survey_part2_survmod.csv'
ref_file = 'Palliative-Survey.csv'

# read in dataframes
df_surv6mo = pd.read_csv(path + db_surv6mo)
df_survprob = pd.read_csv(path + db_survprob)
df_survmod = pd.read_csv(path + db_survmod)

# initialize output dataframes
df_surv6mo_out = pd.DataFrame()
df_survprob_out = pd.DataFrame()
df_survmod_out = pd.DataFrame()

# Set number of columns (= to number of survey takers)
Ncolumns = 10

# compute general performance metrics
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

# compute ROC curve and AUC metrics
def roc(Ypred,Y,E):
    fpr, tpr, roc_auc = [],[],[]
    fpr, tpr, thresholds = metrics.roc_curve(Y[E>0], Ypred[E>0])
    roc_auc = metrics.auc(fpr, tpr)
    return fpr,tpr,roc_auc

# define column names
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


# Calculate ROCs and AUCs for 6 month survival prediction
# survey takers
S1_roc = roc(df_surv6mo['S1 surv'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])
S2_roc = roc(df_surv6mo['S2 surv'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])
S3_roc = roc(df_surv6mo['S3 surv'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])
S4_roc = roc(df_surv6mo['S4 surv'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])
S5_roc = roc(df_surv6mo['S5 surv'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])
S6_roc = roc(df_surv6mo['S6 surv'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])
S7_roc = roc(df_surv6mo['S7 surv'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])
S8_roc = roc(df_surv6mo['S8 surv'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])
S9_roc = roc(df_surv6mo['S9 surv'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])
S10_roc = roc(df_surv6mo['S10 surv'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])
# face age model
PRED_roc = roc(df_surv6mo['6mo survival (pred)'],df_surv6mo['Actual Survival'],df_surv6mo['event flag'])

# Add to dataframe
df_surv6mo_out['S1 surv'] = S1_roc
df_surv6mo_out['S2 surv'] = S2_roc
df_surv6mo_out['S3 surv'] = S3_roc
df_surv6mo_out['S4 surv'] = S4_roc
df_surv6mo_out['S5 surv'] = S5_roc
df_surv6mo_out['S6 surv'] = S6_roc
df_surv6mo_out['S7 surv'] = S7_roc
df_surv6mo_out['S8 surv'] = S8_roc
df_surv6mo_out['S9 surv'] = S9_roc
df_surv6mo_out['S10 surv'] = S10_roc
df_surv6mo_out['Predicted Survival'] = PRED_roc

# Write output to file
df_surv6mo_out.to_csv('survey_p1_AUC_results.csv', index = None)


# Calculate ROCs and AUCs for part 2 predictions with clinical data
# survey takers
S1_roc = roc(df_survprob['S1 surv'],df_survprob['Actual Survival'],df_survprob['event flag'])
S2_roc = roc(df_survprob['S2 surv'],df_survprob['Actual Survival'],df_survprob['event flag'])
S3_roc = roc(df_survprob['S3 surv'],df_survprob['Actual Survival'],df_survprob['event flag'])
S4_roc = roc(df_survprob['S4 surv'],df_survprob['Actual Survival'],df_survprob['event flag'])
S5_roc = roc(df_survprob['S5 surv'],df_survprob['Actual Survival'],df_survprob['event flag'])
S6_roc = roc(df_survprob['S6 surv'],df_survprob['Actual Survival'],df_survprob['event flag'])
S7_roc = roc(df_survprob['S7 surv'],df_survprob['Actual Survival'],df_survprob['event flag'])
S8_roc = roc(df_survprob['S8 surv'],df_survprob['Actual Survival'],df_survprob['event flag'])
S9_roc = roc(df_survprob['S9 surv'],df_survprob['Actual Survival'],df_survprob['event flag'])
S10_roc = roc(df_survprob['S10 surv'],df_survprob['Actual Survival'],df_survprob['event flag'])
# face age model
PRED_roc = roc(df_survprob['6mo survival (pred)'],df_survprob['Actual Survival'],df_survprob['event flag'])

# Add to dataframe
df_survprob_out['S1 surv'] = S1_roc
df_survprob_out['S2 surv'] = S2_roc
df_survprob_out['S3 surv'] = S3_roc
df_survprob_out['S4 surv'] = S4_roc
df_survprob_out['S5 surv'] = S5_roc
df_survprob_out['S6 surv'] = S6_roc
df_survprob_out['S7 surv'] = S7_roc
df_survprob_out['S8 surv'] = S8_roc
df_survprob_out['S9 surv'] = S9_roc
df_survprob_out['S10 surv'] = S10_roc
df_survprob_out['Predicted Survival'] = PRED_roc

# Write output to file
df_survprob_out.to_csv('survey_p2_survprob_AUC_results_minusS9.csv', index = None)


# Calculate ROCs and AUCs for part 2 predictions with risk model and clinical data
# survey takers
S1_roc = roc(df_survmod['S1 surv'],df_survmod['Actual Survival'],df_survmod['event flag'])
S2_roc = roc(df_survmod['S2 surv'],df_survmod['Actual Survival'],df_survmod['event flag'])
S3_roc = roc(df_survmod['S3 surv'],df_survmod['Actual Survival'],df_survmod['event flag'])
S4_roc = roc(df_survmod['S4 surv'],df_survmod['Actual Survival'],df_survmod['event flag'])
S5_roc = roc(df_survmod['S5 surv'],df_survmod['Actual Survival'],df_survmod['event flag'])
S6_roc = roc(df_survmod['S6 surv'],df_survmod['Actual Survival'],df_survmod['event flag'])
S7_roc = roc(df_survmod['S7 surv'],df_survmod['Actual Survival'],df_survmod['event flag'])
S8_roc = roc(df_survmod['S8 surv'],df_survmod['Actual Survival'],df_survmod['event flag'])
S9_roc = roc(df_survmod['S9 surv'],df_survmod['Actual Survival'],df_survmod['event flag'])
S10_roc = roc(df_survmod['S10 surv'],df_survmod['Actual Survival'],df_survmod['event flag'])
# face age model
PRED_roc = roc(df_survmod['6mo survival (pred)'],df_survmod['Actual Survival'],df_survmod['event flag'])

# Add to dataframe
df_survmod_out['S1 surv'] = S1_roc
df_survmod_out['S2 surv'] = S2_roc
df_survmod_out['S3 surv'] = S3_roc
df_survmod_out['S4 surv'] = S4_roc
df_survmod_out['S5 surv'] = S5_roc
df_survmod_out['S6 surv'] = S6_roc
df_survmod_out['S7 surv'] = S7_roc
df_survmod_out['S8 surv'] = S8_roc
df_survmod_out['S9 surv'] = S9_roc
df_survmod_out['S10 surv'] = S10_roc
df_survmod_out['Predicted Survival'] = PRED_roc

# Write output to file
df_survmod_out.to_csv('survey_clinical_AUC_results.csv', index = None)
