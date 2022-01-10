#
# Cox Proportional Hazard Modeling - Harvard Palliative Dataset
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
# AIM 2021


# Import libraries/dependencies
import pickle
import numpy as np
from numpy import load
from numpy import isnan
from pandas import read_csv
from pandas import factorize
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

def time_between(d1, d2, time_mode):
    N = len(d1)
    d1i, d2i = [], []
    age = np.zeros(N,)
    for i in range(N):
        d1[i] = d1[i].replace('_','-')
        d2[i] = d2[i].replace('_','-')
        d1i = datetime.strptime(d1[i], "%Y-%m-%d")
        d2i = datetime.strptime(d2[i], "%Y-%m-%d")
        if time_mode == 'days':
        	age[i] = abs((d2i - d1i).days)
        else:
        	age[i] = abs((d2i - d1i).days)/365
    return age

# significance level
alpha = 0.05

# survival observation time in years (-1 = all time)
T = -1

# define IO paths
rootpath = './'
inputpath = './'

# load master processed file
data = read_csv(rootpath + inputpath + 'palliative_database_curated.csv')

# discard duplicate entries
# data = data.drop_duplicates(subset = 'pin', keep = 'first')
data = data.drop_duplicates()

# Factorize labeled data and assign numeric quantity corresponding to label
Sex = factorize(data['Sex'])
Sex_Type = Sex[0]
Sex_Label = Sex[1]
Race = factorize(data['Race'])
Race_Type = Race[0]
Race_Label = Race[1]
Primary_Diagnosis = factorize(data['Cancer Type'])
Cancer_Type = Primary_Diagnosis[0]
Cancer_Label = Primary_Diagnosis[1]
Site = factorize(data['Site Name'])
Site_Type = Site[0]
Site_Label = Site[1]

sex_label, race_label, cancer_label, site_label = list(),list(),list(),list()
for k in range(len(data)):
    sex_label.append(Sex_Label[Sex_Type[k]])
    race_label.append(Race_Label[Race_Type[k]])
    cancer_label.append(Cancer_Label[Cancer_Type[k]])
    site_label.append(Site_Label[Site_Type[k]])

sex_label = np.asarray(sex_label)
race_label = np.asarray(race_label)
cancer_label = np.asarray(cancer_label)
site_label = np.asarray(site_label)

# Get other covariates of interest from curated database
ECOG = data['ECOG']
RT = data['Prior Pal-RT (anywhere)']
Chemo = data['Prior Pal-Chemo']
Admits = data['Hospital Admits']
ER = data['ER Admits']
mets_bone = data['Mets_bone']
mets_lung = data['Mets_lung']
mets_liver = data['Mets_liver']
mets_brain = data['Mets_brain']
mets_spine = data['Mets_spine']
mets_lymph = data['Mets_lymph']
mets_adrenal = data['Mets_adrenal']
mets_other = data['Mets_other']
first_met_date = data['Date of 1st Met']
diagnosis_date = data['Dt Pri Ca Diag']
consult_date = data['Consult Date']

# get age and survival time data
face_age = data['face age']
chronologic_age = data['chronologic age']
survival_time = data['survival time']
event_flag = data['event flag']

# create dataframe from extracted covariates
df_extract = DF({
                'Sex': Sex_Type,
                'Sex [label]': sex_label,
                'Race': Race_Type,
                'Race [label]': race_label,
                'Cancer Type': Cancer_Type,
                'Cancer Type [label]': cancer_label,
                'Site' : Site_Type,
                'Site [Label]' : site_label,
                'ECOG': ECOG,
                'Prior Pal-Chemo': Chemo,
                'Prior Pal-RT (anywhere)': RT,
                'Hospital Admits': Admits,
                'ER Admits': ER,
                'Mets_bone': mets_bone,
                'Mets_lung': mets_lung,
                'Mets_liver': mets_liver,
                'Mets_brain': mets_brain,
                'Mets_spine': mets_spine,
                'Mets_lymph': mets_lymph,
                'Mets_adrenal': mets_adrenal,
                'Mets_other': mets_other,
                'Date of 1st Met': first_met_date,
                'Dt Pri Ca Diag': diagnosis_date,
                'Consult Date': consult_date,
                'Chronologic Age': chronologic_age,
                'Face Age': face_age,
                'Event Flag': event_flag,
                'Survival Time': survival_time
})
null_index = df_extract.isnull().any(1)
index_condition = 'null_index == False'

# exclude data that are incomplete
Sex_Type = Sex_Type[eval(index_condition)]
sex_label = sex_label[eval(index_condition)]
Race_Type = Race_Type[eval(index_condition)]
race_label = race_label[eval(index_condition)]
Cancer_Type = Cancer_Type[eval(index_condition)]
cancer_label = cancer_label[eval(index_condition)]
Site_Type = Site_Type[eval(index_condition)]
site_label = site_label[eval(index_condition)]
ECOG = ECOG[eval(index_condition)]
RT = RT[eval(index_condition)]
Chemo = Chemo[eval(index_condition)]
Admits = Admits[eval(index_condition)]
ER = ER[eval(index_condition)]
mets_bone = mets_bone[eval(index_condition)]
mets_lung = mets_lung[eval(index_condition)]
mets_liver = mets_liver[eval(index_condition)]
mets_brain = mets_brain[eval(index_condition)]
mets_spine = mets_spine[eval(index_condition)]
mets_lymph = mets_lymph[eval(index_condition)]
mets_adrenal = mets_adrenal[eval(index_condition)]
mets_other = mets_other[eval(index_condition)]
first_met_date = first_met_date[eval(index_condition)]
diagnosis_date = diagnosis_date[eval(index_condition)]
consult_date = consult_date[eval(index_condition)]
face_age = face_age[eval(index_condition)]
age_gap = age_gap[eval(index_condition)]
age_ratio = age_ratio[eval(index_condition)]
chronologic_age = chronologic_age[eval(index_condition)]
survival_time = survival_time[eval(index_condition)]
event_flag = event_flag[eval(index_condition)]

# calculate time from diagnosis to first metastasis
time_to_first_met = time_between(first_met_date.values, diagnosis_date.values, 'years')

# calculate time from radiation therapy consult to first metastasis
time_from_met_to_consult = time_between(consult_date.values, first_met_date.values, 'years')

# renumber some of the labels to match order of TEACHH model publication
N = len(Cancer_Type)
for k in range(N):
    #
    # Cancer Type
    if (cancer_label[k] != 'breast') and \
        (cancer_label[k] != 'prostate') and \
        (cancer_label[k] != 'colorectal') and \
        (cancer_label[k] != 'lung') and \
        (cancer_label[k] != 'gynecological'):
        cancer_label[k] = 'other'
        Cancer_Type[k] = 5
    if cancer_label[k] == 'gynecological':
        Cancer_Type[k] = 3
    #
    # Race
    if (race_label[k] != 'White'):
        race_label[k] = 'Non-White'
        Race_Type[k] = 1

# write updated covariates of interest from curated database
df_extract = DF({
                'Sex': Sex_Type,
                'Sex [label]': sex_label,
                'Race': Race_Type,
                'Race [label]': race_label,
                'Cancer Type': Cancer_Type,
                'Cancer Type [label]': cancer_label,
                'Site' : Site_Type,
                'Site [Label]' : site_label,
                'ECOG': ECOG,
                'Prior Pal-Chemo': Chemo,
                'Prior Pal-RT (anywhere)': RT,
                'Hospital Admits': Admits,
                'ER Admits': ER,
                'Mets_bone': mets_bone,
                'Mets_lung': mets_lung,
                'Mets_liver': mets_liver,
                'Mets_brain': mets_brain,
                'Mets_spine': mets_spine,
                'Mets_lymph': mets_lymph,
                'Mets_adrenal': mets_adrenal,
                'Mets_other': mets_other,
                'Time to 1st Met': time_to_first_met,
                'Time from Met to Consult': time_from_met_to_consult,
                'Chronologic Age': chronologic_age,
                'Face Age': face_age,
                'Age Gap': age_gap,
                'Age Ratio': age_ratio,
                'Event Flag': event_flag,
                'Survival Time': survival_time
})

####  CONVERT to HAZARD-RATIO per 10-YRS  ####
chronologic_age = chronologic_age / 10
face_age = face_age / 10

#censor by observation time if T not equal -1
if T > 0:
    event_flag[survival_time > T] = 0

# show number of events
print(np.sum(event_flag.values))

# create dataframe of categorical covariates
df_categorical = DF({'Sex': Sex_Type,
                     'Race': Race_Type,
                     'Cancer': Cancer_Type,
                     'ECOG': ECOG,
                     'Prior_Pal-Chemo': Chemo,
                     'Prior_Pal-RT' : RT,
                     'Hospital_Admits': Admits,
                     'ER_Admits': ER,
                     'Mets_bone': mets_bone,
                     'Mets_lung': mets_lung,
                     'Mets_liver': mets_liver,
                     'Mets_brain': mets_brain,
                     'Mets_spine': mets_spine,
                     'Mets_lymph': mets_lymph,
                     'Mets_adrenal': mets_adrenal,
                     'Mets_other': mets_other,
                     'Chronologic_age': chrono_age_categorical,
                     'Face_age': face_age_categorical,
                     })

# one-hot encode categorical variables
df_onehot = get_dummies(df_categorical,
                        columns=['Sex',
                                'Race',
                                'Cancer',
                                'ECOG',
                                'Prior_Pal-Chemo',
                                'Prior_Pal-RT',
                                'Hospital_Admits',
                                'ER_Admits',
                                'Mets_bone',
                                'Mets_lung',
                                'Mets_liver',
                                'Mets_brain',
                                'Mets_spine',
                                'Mets_lymph',
                                'Mets_adrenal',
                                'Mets_other',
                                'Chronologic_age',
                                'Face_age',
                                ],
                        drop_first = False)

# create dataframe of continuous covariates
df_continuous = DF({'survival_time': survival_time,
                    'events': event_flag,
                    'Time to 1st Met': time_to_first_met,
                    'Time from Met to Consult': time_from_met_to_consult,
                    #'chronologic age': chronologic_age,
                    'face age': face_age,
                    #'age gap': age_gap,
                    #'age_ratio': age_ratio,
                    #'combined_age': combined_age,
                    })

# assign one-hot encoded categorical covariates to new dataframe
df_cat = DF({
                # Sex = Male, Race = Non-White, Breast = Cancer_4,
                #'pin': pin,
                #'Sex' : df_onehot['Sex_0'],
                #'Race' : df_onehot['Race_1'],
                #'Face Age': df_onehot['Face_age_1.0'],
                #'Chronologic Age': df_onehot['Chronologic_age_1.0'],
                'Lung Cancer' : df_onehot['Cancer_0'],
                'Prostate Cancer': df_onehot['Cancer_1'],
                #'Colorectal Cancer': df_onehot['Cancer_2'],
                #'Gynecologic Cancer': df_onehot['Cancer_3'],
                'Other Cancer': df_onehot['Cancer_5'] + df_onehot['Cancer_3'],
                'ECOG 2' : df_onehot['ECOG_2.0'],
                'ECOG 3-4': df_onehot['ECOG_3.0'] + df_onehot['ECOG_4.0'],
                #'Prior Pal-Chemo (>2 courses)': 1 - (df_onehot['Prior_Pal-Chemo_0.0'] + df_onehot['Prior_Pal-Chemo_1.0'] + df_onehot['Prior_Pal-Chemo_2.0']),
                'Prior Pal-RT (Yes)': df_onehot['Prior_Pal-RT_1.0'] + df_onehot['Prior_Pal-RT_2.0'] + df_onehot['Prior_Pal-RT_3.0'] + df_onehot['Prior_Pal-RT_4.0'],
                'Hospital Admits (Yes)' : df_onehot['Hospital_Admits_1.0'] + df_onehot['Hospital_Admits_2.0'] + df_onehot['Hospital_Admits_3.0'] + df_onehot['Hospital_Admits_4.0'],
                'ER Admits (Yes)' : df_onehot['ER_Admits_1.0'] + df_onehot['ER_Admits_2.0'] + df_onehot['ER_Admits_3.0'] + df_onehot['ER_Admits_4.0'],
                #'Bone Mets': df_onehot['Mets_bone_1'],
                #'Lung Mets': df_onehot['Mets_lung_1'],
                'Liver Mets': df_onehot['Mets_liver_1'],
                'Brain Mets': df_onehot['Mets_brain_1'],
                'Spine Mets': df_onehot['Mets_spine_1'],
                'Adrenal Mets': df_onehot['Mets_adrenal_1'],
                #'Lymph Mets': df_onehot['Mets_lymph_1'],
                'Other Mets': df_onehot['Mets_other_1'],
                })

# create final dataset for Cox PH model
#df_fit = df_continuous
df_fit = merge(df_continuous, df_cat, right_index = True, left_index = True)

# Fit Cox Proportional Hazards model
cph = CoxPHFitter()
cph.fit(df_fit,
         duration_col='survival_time',
         event_col='events',
         show_progress = True)#,
         #strata = ['ecog_4.0'])
cph.print_summary(5)
cph.plot()

# check Cox PH assumption holds
cph.check_assumptions(df_fit, p_value_threshold = 0.05, show_plots = True)
plt.show()

# save Cox PH model
filename = rootpath + 'results/coxph_model.sav'
pickle.dump(cph, open(filename, 'wb'))
