# -----------------
# Database processing - applying exlusion critera to omit ineligible records
# to create curated database
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

# Import libraries/dependencies
import numpy as np
from numpy import load
from numpy import isnan
from pandas import read_csv
from pandas import DataFrame as DF
from pandas import merge
from datetime import datetime
#from keras.models import load_model
#from keras.backend import clear_session
import sys


# cutoff between photo record date and radiation treatment start date
days_cutoff = 30 #1 month ### 90 #3 months

# cutoff between Tx start dates
Tx_start_days_cutoff = 30

# specify the paths
rootpath = './'
datapath = 'data/'

# Function for calculating time between dates/age
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

# load associated log file
csv_log = read_csv(rootpath + datapath + 'database_processed.csv')

# reset dataframe index
#csv_log = csv_log.reset_index(drop=True)

# extract relevant database parameters for applying exclusion criteria
censor_date = csv_log['Last Oncology F/u']
pass_date = csv_log['Date of Death']
photo_date = csv_log['photo_date']
start_date = csv_log['start_date']
Tx_start = csv_log['Tx Start']
birth_date = csv_log['DOB']
course_id = csv_log['Course ID']
curative_intent = csv_log['Curative_Intent']
original_indx = csv_log['original_index']

# find records with missing key reference information
censor_indx = censor_date.isnull().values
pass_indx = pass_date.isnull().values
curative_indx = curative_intent.isnull().values
Tx_start_indx = Tx_start.isnull().values

# omit records that have missing data
censor_date = censor_date[Tx_start_indx == False]
pass_date = pass_date[Tx_start_indx == False]
photo_date = photo_date[Tx_start_indx == False]
start_date = start_date[Tx_start_indx == False]
Tx_start = Tx_start[Tx_start_indx == False]
birth_date = birth_date[Tx_start_indx == False]
course_id = course_id[Tx_start_indx == False]
curative_intent = curative_intent[Tx_start_indx == False]
censor_indx = censor_indx[Tx_start_indx == False]
pass_indx = pass_indx[Tx_start_indx == False]
curative_indx = curative_indx[Tx_start_indx == False]


csv_log_proc = DF({})
indx = 0
for flag in Tx_start_indx:
    if not flag:
        #append row
        csv_log_proc = csv_log_proc.append(csv_log.iloc[[indx]])
    indx += 1

# apply date criteria
delta_indx = (time_between(photo_date.values, start_date.values, 'days') < days_cutoff) \
                & (time_between(Tx_start.values, start_date.values, 'days') < Tx_start_days_cutoff)
# apply course criteria
course_indx = (curative_indx == True) #(course_id.values == 'C1') & (curative_indx == True)

# data consistency check
consistency_date_flg = ((censor_date > start_date) & (pass_date > start_date)) \
                       | ((censor_date > start_date) & (pass_indx == True))

# Create a tuple containing the boolean values of the conditions
proc_conditions = list(zip(censor_indx, pass_indx, delta_indx, consistency_date_flg, course_indx))

proc_df = DF()

# find relevant indices with associated face images and survival data
indx = 0
event_flag, survival_time, chrono_age = list(), list(), list()

#apply criteria excluding records that do not meet them
for condition_i in proc_conditions:
    #print(condition_i)
    #if there is either censor date or passing date, and time cutoff is met, keep record
    if (not condition_i[0] or not condition_i[1]) and condition_i[2] and condition_i[3] and condition_i[4]:
        #cnt += 1
        proc_df = proc_df.append(csv_log_proc.iloc[[indx]])
        chrono_age.append(time_between(birth_date.iloc[[indx]].values, photo_date.iloc[[indx]].values, 'years')[0])
        if not condition_i[1]:
            #has passed away
            event_flag.append(1)
            survival_time.append(time_between(pass_date.iloc[[indx]].values, photo_date.iloc[[indx]].values, 'years')[0])
        else:
            #still alive
            event_flag.append(0)
            survival_time.append(time_between(censor_date.iloc[[indx]].values, photo_date.iloc[[indx]].values, 'years')[0])
    indx += 1

#print(cnt)

# record survival time
survival_df = DF({'pmrn': proc_df['pmrn'],
                  'chronologic age' : chrono_age,
                  'survival time' : survival_time,
                  'event flag': event_flag
                  })

# join processed database files, matched on record number (pmrn)
csv_proc = merge(proc_df, survival_df, on = 'pmrn')

# save dataframe as csv
csv_proc.to_csv(rootpath + datapath + 'database_curated.csv', index = False)
