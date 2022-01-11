#
# Cox Proportional Hazard Modeling - Harvard Thoracic Dataset
#
# The code and data of this repository are intended to promote reproducible research of the paper
# "$PAPER_TITLE"
# Details about the project can be found at the following webpage:
# https://aim.hms.harvard.edu/$FACEAGE_HANDLE

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# AIM 2022


# import libraries/dependencies
import pickle
import numpy as np
from numpy import load
from numpy import isnan
from pandas import read_csv
from pandas import DataFrame as DF
from pandas import merge
from pandas import get_dummies
from datetime import datetime
from lifelines import CoxPHFitter
from lifelines.datasets import load_rossi
from lifelines.datasets import load_regression_dataset
from lifelines.utils import k_fold_cross_validation
from matplotlib import pyplot as plt
import sys

# define IO paths
rootpath = './'
inputpath = './'

# load master processed file
data = read_csv(rootpath + inputpath + 'thoracic_database_curated.csv')

# discard duplicate entries
# data = data.drop_duplicates(subset = 'pin', keep = 'first')
data = data.drop_duplicates()

# get time data and covariates
face_age = data['face age']
chronologic_age = data['chronologic age']
survival_time = data['survival time']
events = data['event flag']
clin_stage = data['clin_stage']
ecog = data['ps']
smoking = data['smoking']
packyears = data['packyears']
bmi = data['BMI']
ethnicity = data['Race[n]']
grade = data['tumorgrade']
gender = data['gender']
clin_stage = data['clin_stage']
t_stage = data['clin_tstage']
n_stage = data['clin_nstage']
m_stage = data['clin_mstage']
Tx_intent = data['Treatment intent']
histo = data['histology (label)']
pin = data['pmrn']

# create dataframe of extracted covariates
df_extract = DF({'gender': gender,
                 'smoking': smoking,
                 'packyears': packyears,
                 'ecog': ecog,
                 'grade': grade,
                 'ethnicity': ethnicity,
                 'clin_stage': clin_stage,
                 'Tx_intent': Tx_intent,
                 'histology' : histo,
                 #'bmi' : bmi,
                 })

# choose clinical stages to analyse
stage_upper = 7
stage_lower = 1

# survival observation time in years (-1 = all time)
T = -1

# condition for data inclusion
index_condition = '(clin_stage >= stage_lower) & (clin_stage <= stage_upper)' \
                        '& (null_index == False)'

# exclude data that are incomplete
null_index = df_extract.isnull().any(1)

survival_time = survival_time[eval(index_condition)]
events = events[eval(index_condition)]
face_age = face_age[eval(index_condition)]
real_age = chronologic_age[eval(index_condition)]
ecog = ecog[eval(index_condition)]
bmi = bmi[eval(index_condition)]
smoking = smoking[eval(index_condition)]
packyears = packyears[eval(index_condition)]
grade = grade[eval(index_condition)]
gender = gender[eval(index_condition)]
ethnicity = ethnicity[eval(index_condition)]
clin_stage = clin_stage[eval(index_condition)]
t_stage = t_stage[eval(index_condition)]
n_stage = n_stage[eval(index_condition)]
m_stage = m_stage[eval(index_condition)]
Tx_intent = Tx_intent[eval(index_condition)]
histo = histo[eval(index_condition)]
pin = pin[eval(index_condition)]

####  CONVERT to HAZARD-RATIO per 10-YRS  ####
real_age = real_age / 10
face_age = face_age / 10

#censor by observation time if T not equal -1
if T > 0:
    events[survival_time > T] = 0

# dataframe of categorical covariates
df_categorical = DF({'gender': gender,
                     'smoking': smoking,
                     'ecog': ecog,
                     'grade': grade,
                     'ethnicity' : ethnicity,
                     'clin_stage': clin_stage,
                     'Tx_intent' : Tx_intent,
                     'histology' : histo,
                     })

# one-hot encode categorical covariates
df_onehot = get_dummies(df_categorical,
                        columns=['gender',
                                'smoking',
                                'ecog',
                                'grade',
                                'ethnicity',
                                'clin_stage',
                                'Tx_intent',
                                'histology'
                                ],
                        drop_first = False)

# create dataframe of continuous covariates
df_continuous = DF({'survival time': survival_time,
                    'events': events,
                    #'bmi' : bmi,
                    #'packyears' : packyears,
                    #'chronologic age (x 0.1/yr)': real_age,
                    'face age (x 0.1/yr)': face_age,
                    #'age_gap': age_gap,
                    #'age_ratio': age_ratio,
                    #'combined_age': combined_age
                    })

# assign one-hot encoded categorical covariates to new dataframe
df_cat = DF({
                #'pin': pin,
                'gender (male)' : df_onehot['gender_1'],
                'smoking (yes/former)' : df_onehot['smoking_1.0'] + df_onehot['smoking_2.0'],
                'ecog > 1' : df_onehot['ecog_2.0'] + df_onehot['ecog_3.0'] + df_onehot['ecog_4.0'],
                #'ecog 2' : df_onehot['ecog_2.0'],
                #'ecog 3-4' : df_onehot['ecog_3.0'] + df_onehot['ecog_4.0'],
                'clin stage II' : df_onehot['clin_stage_3.0'] + df_onehot['clin_stage_4.0'],
                'clin stage III' : df_onehot['clin_stage_5.0'] + df_onehot['clin_stage_6.0'],
                'clin stage IV' : df_onehot['clin_stage_7.0'],
                'tumor grade > 1' : df_onehot['grade_2.0'] + df_onehot['grade_3.0'],
                'ethnicity (non-Caucasian)' : df_onehot['ethnicity_1.0'] + df_onehot['ethnicity_2.0'] + df_onehot['ethnicity_3.0'],
                #'Tx intent: Adjuvant' : df_onehot['Tx_intent_Adjuvant'],
                #'Tx intent: Neoadjuvant' : df_onehot['Tx_intent_Preoperative'],
                #'Tx intent: Perioperative' : df_onehot['Tx_intent_Preoperative and adjuvant'],
                'Tx intent: Curative' : df_onehot['Tx_intent_Radical (definitive)'] + df_onehot['Tx_intent_Adjuvant'] + df_onehot['Tx_intent_Preoperative'] + df_onehot['Tx_intent_Preoperative and adjuvant'],
                #'Tx intent: Palliative': df_onehot['Tx_intent_Palliative'],
                #'Histology: NSCLC (Adeno- or Squamous carcinoma)': df_onehot['histology_Adenocarcinoma (select variant)'] + df_onehot['histology_Adenosquamous carcinoma'] + df_onehot['histology_Squamous cell carcinoma'],
                'Histology: Other': df_onehot['histology_Adenoid cystic carcinoma'] + df_onehot['histology_Atypical carcinoid'] + df_onehot['histology_Large cell carcinoma = NSCLC NOS'] + df_onehot['histology_Large cell neuroendocrine carcinoma = NSCLC with neuroendocrine morphology'] + df_onehot['histology_Metastasis from other site (select primary)'] + df_onehot['histology_No pathology (clinical diagnosis)'] + df_onehot['histology_Other'] + df_onehot['histology_Thymoma'],
                'Histology: SCLC': df_onehot['histology_Small cell lung cancer (SCLC)'] + df_onehot['histology_Mixed NSCLC and SCLC'],
                })

# create final dataset for Cox PH model
#df_fit = df_continuous
df_fit = merge(df_continuous, df_cat, right_index = True, left_index = True)


# fit Cox Proportional Hazards model
cph = CoxPHFitter()
cph.fit(df_fit,
         duration_col='survival time',
         event_col='events',
         show_progress = True)#,
         #strata = ['ecog_4.0'])
cph.print_summary(5)
cph.plot()

# save Cox PH model
filename = rootpath + 'results/coxph_model.sav'
pickle.dump(cph, open(filename, 'wb'))

# check PH assumption
cph.check_assumptions(df_fit, p_value_threshold = 0.05, show_plots = True)
plt.show()
