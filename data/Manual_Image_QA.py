#
# Manual photo QA and curation script
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
# AIM 2022


# Osbert Zalay 2021

# import libraries/dependencies
import matplotlib
matplotlib.use('TkAgg')

import numpy as np
from pandas import DataFrame as DF
from pandas import read_csv
from PIL import Image
from matplotlib import pyplot as plt
import cv2
import sys

# define IO paths
inputpath = './'
outputpath = './'
facepath = './'

# load faces
data = np.load(facepath + 'extracted_faces.npz')
X = data['arr_0']

# read logfile pertaining to dataset and load image reference information for tracking
df_log = read_csv(inputpath + 'logfile.csv')
pmrn_log = df_log['pmrn'] #record number
photo_log = df_log['photo_id']
# read csv file containing clinical dataset pertaining to extracted face images
df_data = read_csv(inputpath + 'database_curated.csv')
pmrn_data = df_data['pmrn'] #record number
yhat = df_data['face age'].values
testy = df_data['chronologic age'].values

# match the data to the information in the logfile by record number
N_data = len(pmrn_data)
indx = []
for i in range(N_data):
    indx.append(np.where(pmrn_log == pmrn_data.iloc[i])[0][0])
testX = X[indx,:,:,:]

# set image/text display parameters
font = cv2.FONT_HERSHEY_SIMPLEX
locationText = (40,40)
outlierText = (150,25)
idText = (10,390)
fontScale = 0.5
fontColor = (255,255,255)
lineType = 2
scale_percent = 250 # percent of original size

fig = plt.figure()


# initialize index for determining which images to cull or keep
cnt = 0
cullindx = np.ones((N_data,))
continuing_to_review = True

# Main Loop for reviewing/QA of images
while continuing_to_review:
    #id_i = 'Visualizing file: %s' % sbrt_id[cnt]
    face_pixels = testX[cnt,:,:,:]
    face_image = Image.fromarray(face_pixels.astype(np.uint8))
    width = int(face_pixels.shape[0] * scale_percent / 100)
    height = int(face_pixels.shape[1] * scale_percent / 100)
    resized_face = cv2.resize(face_pixels, (width, height), interpolation = cv2.INTER_AREA)

    fig.canvas.flush_events()
    #display the image
    #cv2.imshow(id_i, resized_face[:, :, [2, 1, 0]])  # BGR (not RGB) ordering of channels
    cv2.imshow('Visualizing Results', resized_face[:,:,[2,1,0]]) #BGR (not RGB) ordering of channels
    #cv2.imshow('plot', img)
    cnt += 1
    if cnt > N_data-1:
        cnt = N_data-1
    #wait for a keypress
    key = cv2.waitKey(0)
    #print(key)
    # Manually iterate through images to view them (can go forwards and backwards)
    if key == 27 or key == ord('q'):
        #Escape key (ascii value = 27) to terminate program and write selected images
        if np.sum(cullindx) < N_data:
            print('Writing culled dataset to file...')
            culled_df = DF()
            for i in range(N_data):
                # if image not removed from dataset, add it to output file
                if cullindx[i]:
                    culled_df = culled_df.append(df_data.iloc[i])[df_data.columns.tolist()]
            culled_df.to_csv(outputpath + 'database_culled.csv')
            print('Done.')
        continuing_to_review = False
    # Arrow keys 'x1b[K' where '[A' = up '[B' = down '[C' = right '[D' = left
    #elif key == '\x1b[B' or key == '\x1b[D':
    #elif key == 81 or key == 84:  # up/down keys
    elif key == 52 or key == 53:
        cnt = cnt - 2 # go backwards
        if cnt < 0:
            cnt = 0
    elif key == ord('c') or key == ord('C'):
        # cull image (i.e. remove from dataset)
        cnt = cnt - 1
        cullindx[cnt] = 0
        print('Culled record %d' % pmrn_data.iloc[cnt])
    elif key == 8:
        # undo cull
        cnt = cnt - 1
        cullindx[cnt] = 1
        print('Restored record %d' % pmrn_data.iloc[cnt])
    else:
        continue
        # save the new culled validation image arrays
