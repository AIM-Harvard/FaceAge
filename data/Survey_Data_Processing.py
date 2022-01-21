# -----------------
# Script for processing survey data
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
import sys

## SELECT which survey predictor ##
#VAR = 'age'
VAR = 'survival'

## SELECT which survey part ##
PART = 1
#PART = 2

path = './'
#read survey part X results to dataframe
db_file = 'survey_part' + str(PART) + '_' + VAR + '.csv'
df = pd.read_csv(path + db_file)
#read database of 100 randomly selected palliative patients
ref_file = 'Palliative-Survey-subgroup.csv'
df_ref = pd.read_csv(path + ref_file)

#create temporary dataframe referenced to photo id and record number
df_temp = pd.DataFrame()
df_temp['Photo ID'] = df_ref['Photo ID']
df_temp['pmrn'] = df_ref['pmrn']

# extract relevant covariates, event information and survival times by survey part
if PART == 1:
    if VAR == 'age':
        df_temp['chronologic age'] = df_ref['chronologic age']
        df_temp['face age'] = df_ref['face age']
    else:
        df_temp['chronologic age'] = df_ref['chronologic age']
        df_temp['face age'] = df_ref['face age']
        df_temp['survival time'] = df_ref['survival time']
        df_temp['event flag'] = df_ref['event flag']
        df_temp['6mo survival (pred)'] = df_ref['CPH T = 0.5 years']

# merge results (survey taker predictions) with model predictions and clinical outcomes data
df_out = df.merge(df_temp, on = 'Photo ID')
#write to file
df_out.to_csv(path + 'survey_part' + str(PART) + '_' + VAR + '_out.csv', index = False)
