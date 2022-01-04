#
# Database processing to include entries that have face image
#
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

# import libraries/dependencies
import numpy as np
from numpy import load
from numpy import isnan
from pandas import read_csv
from pandas import DataFrame as DF
from pandas import merge
from keras.models import load_model
from keras.backend import clear_session
import sys


# specify the IO paths
rootpath = './'
datapath = 'data/'

# load associated log file with record identifier information
csv_log = read_csv(rootpath + datapath + 'logfile.csv')

# get record numbers
pmrn = csv_log['pmrn']
pmrn = np.asarray(pmrn)

# load raw clinical database
csv_data = read_csv(rootpath + datapath + 'database.csv')

# find relevant indices with associated face images
keep_indx = []
flag = []
proc_df = DF()
yhat_df = DF()

for elem in pmrn:
    #locate records in dataset matching logfile and indicate if found:
    flag = not not csv_data['pmrn'][csv_data['pmrn'] == elem].tolist()
    if flag:
        #if face image pertaining to data entry exists, append data to output dataframe
        proc_df = proc_df.append(csv_data[csv_data['pmrn'] == elem].iloc[0])[csv_data.columns.tolist()]
        yhat_df = yhat_df.append(csv_log[csv_log['pmrn'] == elem].iloc[0])[csv_log.columns.tolist()]

#sort results by record number
proc_df = proc_df.sort_values(by = 'pmrn')
yhat_df = yhat_df.sort_values(by = 'pmrn')

# drop redundant columns
yhat_df = yhat_df.drop('face flag', axis = 1)

# concatenate dataframes
csv_data = merge(proc_df, yhat_df, on = 'pmrn')

# save output dataframe as csv
csv_data.to_csv(rootpath + datapath + 'database_processed.csv', index = False)
