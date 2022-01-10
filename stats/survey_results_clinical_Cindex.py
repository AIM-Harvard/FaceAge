import pandas as pd
import numpy as np
from sklearn import metrics
from lifelines.utils import concordance_index
import sys

# inputs
path = './'
db_survprob = 'survey_part2_survprob.csv'
db_survmod = 'survey_part2_survmod.csv'
ref_file = 'Palliative-Survey.csv'

# read in dataframes
df_survprob = pd.read_csv(path + db_survprob)
df_survmod = pd.read_csv(path + db_survmod)

# initialize output dataframes
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

# compute C-Index
def CI(Ypred,Y,E):
    ci = concordance_index(Y, Ypred, E)
    return ci


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

# Calculate C-index for part 2 predictions with clinical data
# survey takers
S1_CI = CI(df_survprob['S1 surv'],df_survprob['survival time'],df_survprob['event flag'])
S2_CI = CI(df_survprob['S2 surv'],df_survprob['survival time'],df_survprob['event flag'])
S3_CI = CI(df_survprob['S3 surv'],df_survprob['survival time'],df_survprob['event flag'])
S4_CI = CI(df_survprob['S4 surv'],df_survprob['survival time'],df_survprob['event flag'])
S5_CI = CI(df_survprob['S5 surv'],df_survprob['survival time'],df_survprob['event flag'])
S6_CI = CI(df_survprob['S6 surv'],df_survprob['survival time'],df_survprob['event flag'])
S7_CI = CI(df_survprob['S7 surv'],df_survprob['survival time'],df_survprob['event flag'])
S8_CI = CI(df_survprob['S8 surv'],df_survprob['survival time'],df_survprob['event flag'])
S10_CI = CI(df_survprob['S10 surv'],df_survprob['survival time'],df_survprob['event flag'])
S11_CI = CI(df_survprob['S11 surv'],df_survprob['survival time'],df_survprob['event flag'])
# face age model
PRED_CI = CI(df_survprob['6mo survival (pred)'],df_survprob['survival time'],df_survprob['event flag'])

# add to dataframe
df_survprob_out['S1 surv'] = S1_CI
df_survprob_out['S2 surv'] = S2_CI
df_survprob_out['S3 surv'] = S3_CI
df_survprob_out['S4 surv'] = S4_CI
df_survprob_out['S5 surv'] = S5_CI
df_survprob_out['S6 surv'] = S6_CI
df_survprob_out['S7 surv'] = S7_CI
df_survprob_out['S8 surv'] = S8_CI
df_survprob_out['S10 surv'] = S10_CI
df_survprob_out['S11 surv'] = S11_CI
df_survprob_out['Predicted Survival'] = PRED_CI

# Write output to file
df_survprob_out.to_csv('survey_p2_survprob_results_minusS9.csv', index = None)


# Calculate C-index for part 2 predictions with risk model and clinical data
# survey takers
S1_CI = CI(df_survmod['S1 surv'],df_survmod['survival time'],df_survmod['event flag'])
S2_CI = CI(df_survmod['S2 surv'],df_survmod['survival time'],df_survmod['event flag'])
S3_CI = CI(df_survmod['S3 surv'],df_survmod['survival time'],df_survmod['event flag'])
S4_CI = CI(df_survmod['S4 surv'],df_survmod['survival time'],df_survmod['event flag'])
S5_CI = CI(df_survmod['S5 surv'],df_survmod['survival time'],df_survmod['event flag'])
S6_CI = CI(df_survmod['S6 surv'],df_survmod['survival time'],df_survmod['event flag'])
S7_CI = CI(df_survmod['S7 surv'],df_survmod['survival time'],df_survmod['event flag'])
S8_CI = CI(df_survmod['S8 surv'],df_survmod['survival time'],df_survmod['event flag'])
S10_CI = CI(df_survmod['S10 surv'],df_survmod['survival time'],df_survmod['event flag'])
S11_CI = CI(df_survmod['S11 surv'],df_survmod['survival time'],df_survmod['event flag'])
# face age model
PRED_CI = CI(df_survmod['6mo survival (pred)'],df_survmod['survival time'],df_survmod['event flag'])

# add to dataframe
df_survmod_out['S1 surv'] = S1_CI
df_survmod_out['S2 surv'] = S2_CI
df_survmod_out['S3 surv'] = S3_CI
df_survmod_out['S4 surv'] = S4_CI
df_survmod_out['S5 surv'] = S5_CI
df_survmod_out['S6 surv'] = S6_CI
df_survmod_out['S7 surv'] = S7_CI
df_survmod_out['S8 surv'] = S8_CI
df_survmod_out['S10 surv'] = S10_CI
df_survmod_out['S11 surv'] = S11_CI
df_survmod_out['Predicted Survival'] = PRED_CI

# Write output to file
df_survmod_out.to_csv('survey_p2_survmod_results_minusS9.csv', index = None)
