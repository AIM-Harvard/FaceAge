#
# Extract Face Images using MTCNN (Zhang et al. 2015). This is the first
# stage of the deep-learning FaceAge pipeline
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

# Import libraries/dependencies
import os
from datetime import datetime
from pandas import read_csv
from pandas import DataFrame as DF
from PIL import Image
from numpy import asarray
from numpy import where
from numpy import savez_compressed
from mtcnn.mtcnn import MTCNN
from imghdr import what
from time import sleep

#disable annoying AVX warning due to GPU usage
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'


# define IO paths
rootpath = './'
datapath = 'data/'
inputpath = 'input/'
outputpath = 'extracted-faces/'

# Extract numerical date from abreviated date string format in clinical database
def date_extract(datestr):
    N = len(datestr)
    dates = list()
    for i in range(N):
        date_i = datetime.strptime(datestr[i], "%m/%d/%Y %H:%M:%S %p").date()
        dates.append(date_i)
    return dates

# extract face array from each separate file
def extract_face(filename, required_size=(160, 160)):
	# load image from file
	image = Image.open(filename)
	# convert to RGB, if needed
	image = image.convert('RGB')
	# convert to array
	pixels = asarray(image)
	# initialize face detector
	detector = MTCNN()
	# detect faces in the image
	results = detector.detect_faces(pixels)
	face_flag = 0
	if not results:
		# if no face detected then return empty array
		face_array = asarray([])
	else:
		# extract the bounding box from the first face
		x1, y1, width, height = results[0]['box']
		# bug fix
		x1, y1 = abs(x1), abs(y1)
		x2, y2 = x1 + width, y1 + height
	# extract the face
		face = pixels[y1:y2, x1:x2]
	# resize pixels to the model size
		image = Image.fromarray(face)
		image = image.resize(required_size)
		face_array = asarray(image)
		face_flag = 1
	return face_array, face_flag


# load images and extract faces for all images in a directory separating by age
def load_dataset(directory, filenames):
    # initialize indices for faces to be extracted
    faces = list()
    face_flag_indx = list()
    # enumerate files
    cnt=0
    Nfiles = len(filenames)
    # Main Loop for extracting faces from image files
    for file in filenames:
        cnt+=1
        path = directory + file + '.jpg'
        # check if valid stored Image
        im = Image.open(path)
        # get dimensions of image
        width, height = im.size
        # check correct format of image
        imgfiletype = what(path)
        if width < 2 | height < 2:
        	continue
        if imgfiletype != 'jpeg':
        	continue
        # extract face
        face, face_flag = extract_face(path)
        # only include if face was detected
        if size(face):
            # append extracted face and record
            faces.append(face)
            face_flag_indx.append(face_flag)
        # display file being processed
        print('Processing file %d' % cnt, 'of %d,' % Nfiles, ' FILE: %s' % file, '\n')
    return asarray(faces), face_flag_indx
# load a dataset that contains one subdir for each class that in turn contains images

# Extract data and match patient id
csv_log = read_csv(rootpath + datapath + 'logfile.csv')
log_pmrn = csv_log.Old_PatientId
log_id = csv_log.New_PatientId
start_date = csv_log['Start Date']

indx = ((log_id.isnull().values) | (start_date.isnull().values))
id = (log_pmrn[indx == False], log_id[indx == False])

# load dataset
faces, face_flag_indx = load_dataset(rootpath + inputpath, id[1])

# create dataframe of processed clinical face records
face_id = DF({'original_index' : where(indx == False)[0],
		   'pmrn': id[0],
		   'photo_id': id[1],
		   'photo_date': csv_log['Creation Date'][indx == False],
		   'start_date': date_extract(start_date[indx == False].values),
		   'face flag': face_flag_indx})
# Write record information to logfile
face_id.to_csv(path_or_buf = (rootpath + datapath + 'logfile.csv'), index = False)

# save extracted face array to one file in compressed format
savez_compressed(rootpath + outputpath + 'extracted_faces.npz', faces)
