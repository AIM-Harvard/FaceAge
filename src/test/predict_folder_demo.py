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
import yaml
import argparse

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

## ----------------------------------------

def get_face_bbox_from_image(path_to_image):
  
  """
  Use the MTCNN face detector to localise the subject's face withing the image.
  Returns the coordinates to draw bounding box enclosing the face,
  the keypoints coordinates, and the confidence associated with the prediction.
  
  Make sure the image contains only one subject for the pipeline to work as intended.

  @params:
    path_to_image - required: absolute path to the image file to be processed.
     
   """

  # sanity check
  assert os.path.exists(path_to_image)

  pat_img = imread(path_to_image)
  
  try:
    # return the MTCNN output associated with the first face found in the image
    # make sure the image contains only one subject for the pipeline to work as intended
    return mtcnn.mtcnn.MTCNN().detect_faces(pat_img)[0]
  except:
    print('ERROR: Processing error for file "%s"'%(path_to_image))
    return dict()

## ----------------------------------------

def get_model_prediction(model, path_to_image, mtcnn_output_dict):
  
  """
  Get the FaceAge estimation for the given image.
  Requires a bounding box (around the face) to be computed prior to this step.

  @params:
    model - required: the object storing the pre-trained (TF) FaceAge model
    path_to_image - required: absolute path to the image file to be processed.
    mtcnn_output_dict - required: dictionary storing the aforementioned bounding box
      (e.g., obtained from the MTCNN face detector, by running "get_face_bbox_from_image")
     
   """

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

## ----------------------------------------
## ----------------------------------------

def main(config):

  model_name = config["model_name"]
  base_model_path = config["base_model_path"]

  base_output_path = config["base_output_path"]

  input_folder_name = config["input_folder_name"]
  input_folder_path = config["input_folder_path"]

  input_file_list = [f for f in os.listdir(input_folder_path) if ".jpg" in f]

  print("Predicting FaceAge for %g subjects at: '%s'\n"%(len(input_file_list),
                                                         input_folder_path))


  face_bbox_dict = dict()

  # FIXME: DEBUG
  # limit the number of subjects for a faster execution
  # if set to -1, run on all the hi-res UTK data (provided)
  N_SUBJECTS = -1

  # subset the file list to speed up the execution of the whole notebook
  input_file_list = input_file_list[:N_SUBJECTS] if N_SUBJECTS > 0 else input_file_list


  for idx, input_image in enumerate(input_file_list):

    subj_id = input_image.split(".")[0]

    print('(%g/%g) Running the face localization step for "%s"'%(idx + 1,
                                                                len(input_file_list),
                                                                input_image),
    end = "\r")

    path_to_image = os.path.join(input_folder_path, input_image)
    
    face_bbox_dict[subj_id] = dict()
    
    face_bbox_dict[subj_id]["path_to_image"] = path_to_image

    face_bbox_dict[subj_id]["mtcnn_output_dict"] = get_face_bbox_from_image(path_to_image)

  # ------------------------

  model_path = os.path.join(base_model_path, model_name)
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

  outfile_name = '%s_res.csv'%(input_folder_name)
  outfile_path = os.path.join(base_output_path, outfile_name) 

  print("\nSaving predictions at: '%s'... "%(outfile_path), end = "")

  age_pred_df.to_csv(outfile_path, index = False)

  print("Done.")


## ----------------------------------------
## ----------------------------------------
      
if __name__ == '__main__':

  base_conf_file_path = '.'
  
  parser = argparse.ArgumentParser(description = 'FaceAge - predict folder demo')

  parser.add_argument('--conf',
                      required = False,
                      help = 'Specify the path to the YAML configuration file containing the run details.',
                      default = "config_predict_folder_demo.yaml"
                     )

  args = parser.parse_args()

  conf_file_path = os.path.join(base_conf_file_path, args.conf)

  with open(conf_file_path) as f:
    yaml_conf = yaml.load(f, Loader = yaml.FullLoader)

  # base data directory
  base_path = yaml_conf["test"]["base_path"]

  data_folder_name = yaml_conf["test"]["data_folder_name"]

  model_name = yaml_conf["test"]["model_name"]
  models_folder_name = yaml_conf["test"]["models_folder_name"]

  input_folder_name = yaml_conf["test"]["input_folder_name"]
  outputs_folder_name = yaml_conf["test"]["outputs_folder_name"]

  base_data_path = os.path.join(base_path, data_folder_name)
  base_model_path = os.path.join(base_path, models_folder_name)
  base_output_path = os.path.join(base_path, outputs_folder_name)

  input_folder_path = os.path.join(base_data_path, input_folder_name)

  ## ----------------------------------------
  
  # dictionary to be passed to the main function
  config = dict()
  
  config["base_model_path"] = base_model_path
  config["model_name"] = model_name + ".h5" if model_name.split(".")[-1] != "h5" else model_name

  config["base_output_path"] = base_output_path
  
  config["input_folder_name"] = input_folder_name
  config["input_folder_path"] = input_folder_path
  
  main(config)