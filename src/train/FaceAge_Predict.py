# -----------------
# Predict FaceAge from extracted faces via face feature embedding and regression
# (Stage 2 of FaceAge deep learning pipeline)
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
from pandas import read_csv
from pandas import DataFrame as DF
from keras.models import load_model
from keras.backend import clear_session

def standardize(face_pixels):
	# set pixel precision
	face_pixels = face_pixels.astype('float32')
	# standardize pixel values across channels (global)
	for i in range(np.shape(face_pixels)[0]):
		mean, std = face_pixels[i,:,:,:].mean(), face_pixels[i,:,:,:].std()
		face_pixels[i,:,:,:] = (face_pixels[i,:,:,:] - mean) / std
	return face_pixels

# specify the embedding version of inception-resnet v1 CNN
version = 128;
rootpath = './'
inputpath = 'input/'
workpath = 'work/'
#outputpath = 'results/'
outputpath = inputpath
if version == 128:
	# use the 128-Dimensional face embedding version
	model = load_model('./faceage128.h5')
elif version == 512:
	# use the 512-Dimensional face embedding version
	model = load_model('./faceage512.h5')

# print model summary
model.summary()

# load dataset of face images for evaluation
data = load(rootpath + workpath + 'extracted_faces.npz')
X = data['arr_0']

# load associated log file with record information
csv_log = read_csv(rootpath + inputpath + 'logfile.csv')

# predict class probabilities
yhat = model.predict(standardize(X))

# create dataframe of output predictions
yhat_df = DF({'face age': yhat[:,0]})

# add to existing dataframe
csv_log['face age'] = yhat_df['face age']

# tidy up and close session
#del model
clear_session()

# save dataframe as csv
csv_log.to_csv(rootpath + outputpath + 'predictions.csv', index = False)
