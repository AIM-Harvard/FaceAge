# -----------------
# FaceAge Deep Learning Model Development and Training
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
from keras import models
from keras import layers
from keras import optimizers
from keras.utils import multi_gpu_model
from keras.callbacks import EarlyStopping
from keras.callbacks import ReduceLROnPlateau
from keras.callbacks import History
from keras.backend import clear_session
from keras.models import load_model
from matplotlib import pyplot as plt
import sys


# Define IO paths
rootpath = './model/'
inputpath = 'input/'


# CNN layer name generator
def _generate_layer_name(name, branch_idx=None, prefix=None):
    if prefix is None:
        return None
    if branch_idx is None:
        return '_'.join((prefix, name))
    return '_'.join((prefix, 'Branch', str(branch_idx), name))

# Standard normalization of extracted face images
def standardize(face_pixels):
	# scale pixel values
	face_pixels = face_pixels.astype('float32')
	# standardize pixel values across channels (global)
	for i in range(np.shape(face_pixels)[0]):
		mean, std = face_pixels[i,:,:,:].mean(), face_pixels[i,:,:,:].std()
		face_pixels[i,:,:,:] = (face_pixels[i,:,:,:] - mean) / std
	# transform face into one sample
	#face_image = expand_dims(face_pixels, axis=0)
	return face_pixels

# specify the embedding version of inception-resnet v1 CNN
version = 128;

if version == 128:
	# use the 128-Dimension face embedding version
	inception_resnet_v1 = load_model(rootpath + 'inception_resnet_128.h5')
elif version == 512:
	# use the 512-Dimension face embedding version
	inception_resnet_v1 = load_model(rootpath + 'inception_resnet_512.h5')

# Choose which layers to train
Cutoff_Layer =  145  # train layers further downstream of this cutoff
for layer in inception_resnet_v1.layers[0:(Cutoff_Layer - 1)]:
    layer.trainable = False
for layer in inception_resnet_v1.layers[Cutoff_Layer:]:
	layer.trainable = True

# initialize new model
model = models.Sequential()

# use inception-resnet v1 architecture as base CNN face feature extractor
model.add(inception_resnet_v1)

# add dense (fully-connected) layer 1
model.add(layers.Dense(version, activation='relu'))

# batch normalization
bn_name = _generate_layer_name('BatchNorm', prefix='dense_1')
model.add(layers.BatchNormalization(momentum=0.995, epsilon=0.001, scale=False, name=bn_name))

# Add linear output regression layer
model.add(layers.Dense(1, activation='linear'))

# run on 2 GPUs
parallel_model = multi_gpu_model(model, gpus=2)

# model reporting
parallel_model.summary()

# compile the model and select optimizer ("Adam" stochastic backpropagation with momentum method)
parallel_model.compile(loss='mean_absolute_error',
	optimizer=optimizers.Adam(lr=0.001, beta_1=0.9, beta_2=0.999, epsilon=None, decay=0.0, amsgrad=False),
	metrics=['mae'])

# load datasets for training and validation
rawdata = load(rootpath + inputpath + 'extracted_faces_training.npz')
data, labels = rawdata['arr_0'], rawdata['arr_1']

Nval = data.shape[0]

#validation fraction
val_frac = 0.1

# create training and test datasets from original pre-randomized, augmented and rebalanced development dataset
trainX = data[:(int((1-val_frac)*Nval)),:]
trainy = labels[:(int((1-val_frac)*Nval))]
testX = data[(int((1-val_frac)*Nval)+1):Nval,:]
testy = labels[(int((1-val_frac)*Nval)+1):Nval]

print('Dataset: train=%d, test=%d' % (trainX.shape[0], testX.shape[0]))

# Train the model, iterating on the data in batches of 32 samples
np.random.seed()

# Callbacks for monitoring and controlling training progress:
# early stopping if performance no longer improving
early = EarlyStopping(monitor='val_loss', min_delta=1e-08, patience=200, verbose=0, mode='min', baseline=None,
						  restore_best_weights=True)

# reduce learning rate if loss function plateaus
lr_reduce = ReduceLROnPlateau(monitor='val_loss', factor=0.2, patience=5, verbose=0, mode='min', min_delta=0.0001, cooldown=2, min_lr=1e-15)

# record training events
history = History()

# Fit the deep learning model
parallel_model.fit(standardize(trainX), trainy, epochs=1000, batch_size=256,
					validation_data=(standardize(testX),testy), shuffle = True, callbacks = [early, lr_reduce, history])

#retrieve the core model from the 2-GPU concatenated parallel model
model = parallel_model.get_layer('sequential_1')

# write the trained deep learning model to file
model.save(rootpath + 'facenet.h5', overwrite=True)

# get training and validation results
acc = history.history['mean_absolute_error']
val_acc = history.history['val_mean_absolute_error']
loss = history.history['loss']
val_loss = history.history['val_loss']

epochs = range(len(acc))

# plot the results
plt.plot(epochs, acc, 'b', label='Training MAE')
plt.plot(epochs, val_acc, 'r', label='Validation MAE')
plt.title('Training and validation accuracy')
plt.legend()

plt.figure()

plt.plot(epochs, loss, 'b', label='Training loss')
plt.plot(epochs, val_loss, 'r', label='Validation loss')
plt.title('Training and validation loss')
plt.legend()

plt.show()

# tidy up and close session
del model, inception_resnet_v1
clear_session()
