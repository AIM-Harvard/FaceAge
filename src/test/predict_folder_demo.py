# The code and data of this repository are intended to promote reproducible research of the paper
# "$PAPER_TITLE"
# Details about the project can be found at the following webpage:
# https://aim.hms.harvard.edu/$FACEAGE_HANDLE

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# AIM 2022

import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

import sys
import PIL
import mtcnn
import keras
import numpy as np
import pandas as pd
import tensorflow as tf

# suppress warnings/errors due to migration from TensorFlow 1.x to 2.x
tf.compat.v1.disable_eager_execution()
tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.ERROR)

from skimage.io import imsave, imread


print("Python version     : ", sys.version.split('\n')[0])
print("TensorFlow version : ", tf.__version__)
print("Keras version      : ", keras.__version__)
print("Numpy version      : ", np.__version__)
print("")

def get_face_bbox_from_image(path_to_image):
  
  # sanity check
  assert os.path.exists(path_to_image)

  pat_img = imread(path_to_image)
  
  try:
    return mtcnn.mtcnn.MTCNN().detect_faces(pat_img)[0]
  except:
    # patient
    print('ERROR: Processing error for file "%s"'%(path_to_image))
    return dict()

# ------------------------

def get_model_prediction(model, path_to_image, mtcnn_output_dict):
  
  # sanity check
  assert os.path.exists(path_to_image)

  pat_img = imread(path_to_image)

  # extract the bounding box from the first face
  x1, y1, width, height = mtcnn_output_dict['box']
  x1, y1 = abs(x1), abs(y1)
  x2, y2 = x1 + width, y1 + height

  # crop the face
  pat_face = pat_img[y1:y2, x1:x2]

  # resize cropped image to the model input size
  pat_face_pil = PIL.Image.fromarray(np.uint8(pat_face)).convert('RGB')
  pat_face = np.asarray(pat_face_pil.resize((160, 160)))
  
  # prep image for TF processing
  mean, std = pat_face.mean(), pat_face.std()
  pat_face = (pat_face - mean) / std
  pat_face_input = pat_face.reshape(1, 160, 160, 3)
  
  return np.squeeze(model.predict(pat_face_input))

# ------------------------
# ------------------------

# fixme: parse from config file
PROJECT_PATH = "/home/dennis/git/FaceAge/"

BASE_DATA_PATH = os.path.join(PROJECT_PATH, "data")
BASE_MODEL_PATH = os.path.join(PROJECT_PATH, "models")
BASE_OUTPUT_PATH = os.path.join(PROJECT_PATH, "outputs")

FOLDER_NAME = "test"

input_base_path = os.path.join(BASE_DATA_PATH, FOLDER_NAME)
input_file_list = [f for f in os.listdir(input_base_path) if ".jpg" in f]

print("Predicting FaceAge for %g subjects at: '%s'\n"%(len(input_file_list),
                                                       input_base_path))


face_bbox_dict = dict()

# limit the number of subjects for a faster execution
# if set to -1, run on all the hi-res UTK data (provided)
N_SUBJECTS = 10

# subset the file list to speed up the execution of the whole notebook
input_file_list = input_file_list[:N_SUBJECTS] if N_SUBJECTS > 0 else input_file_list


for idx, input_image in enumerate(input_file_list):

  subj_id = input_image.split(".")[0]

  print('(%g/%g) Running the face localization step for "%s"'%(idx + 1,
                                                               len(input_file_list),
                                                               input_image),
  end = "\r")

  path_to_image = os.path.join(input_base_path, input_image)
  
  face_bbox_dict[subj_id] = dict()
  
  face_bbox_dict[subj_id]["path_to_image"] = path_to_image

  face_bbox_dict[subj_id]["mtcnn_output_dict"] = get_face_bbox_from_image(path_to_image)

# ------------------------

model_path = os.path.join(BASE_MODEL_PATH, "faceage_model.h5")
model = keras.models.load_model(model_path)

print("")

age_pred_dict = dict()

for idx, subj_id in enumerate(face_bbox_dict.keys()):
  
  print('(%g/%g) Running the age estimation step for "%s"'%(idx + 1,
                                                            len(face_bbox_dict),
                                                            subj_id),
  end = "\r")

  path_to_image = face_bbox_dict[subj_id]["path_to_image"]
  mtcnn_output_dict = face_bbox_dict[subj_id]["mtcnn_output_dict"]

  age_pred_dict[subj_id] = dict()

  age_pred_dict[subj_id]["faceage"] = get_model_prediction(model, path_to_image, mtcnn_output_dict)


age_pred_df = pd.DataFrame.from_dict(age_pred_dict, orient = 'index')
age_pred_df.reset_index(level = 0, inplace = True)
age_pred_df.rename(columns = {"index": "subj_id"}, inplace = True)

outfile_name = '%s_res.csv'%(FOLDER_NAME)
outfile_path = os.path.join(BASE_OUTPUT_PATH, outfile_name) 

print("\nSaving predictions at: '%s'... "%(outfile_path), end = "")

age_pred_df.to_csv(outfile_path, index = False)

print("Done.")
