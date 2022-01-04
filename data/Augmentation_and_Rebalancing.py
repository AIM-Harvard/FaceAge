#
# Script for automated randomized rebalancing and augmentation of training data
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
import numpy as np
from numpy import load
from numpy import savez_compressed
from matplotlib import pyplot as plt
from keras.preprocessing.image import ImageDataGenerator
from time import sleep

# define IO paths
rootpath = './'

# define target number of samples per age category and batch size
Nval = 150 #int(6100/(105-18))
batchsz = 20
# define age bounds
upper_age = 105
lower_age = 18

# indicate filename for training/validation dataset
stem = 'extracted_18_105_culled_60_105_'
datalist = ['wiki-imdb']

#instantiate ImageDataGen object for augmentation
datagen = ImageDataGenerator(
        # paramaters for augmentation (shifts, rotations, flips, shear, etc.)
        samplewise_center = False,
        samplewise_std_normalization = False,
        rotation_range=20,
        width_shift_range=0.1,
        height_shift_range=0.1,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='constant')

# Augmentation subroutine with batch processing
def augment(X, y, Nval, datagen, batchsz):
    # fit the transformation statistics to the data
    datagen.fit(X)
    N0 = len(y)
    N1 = []
    i = 0
    for batch in datagen.flow(X, y, batch_size=batchsz, shuffle=True):
        if not i:
            newX = batch[0]
            newy = batch[1]
        else:
            newX = np.concatenate([newX, batch[0]])
            newy = np.concatenate([newy, batch[1]])
        print('Processing augmentation batch %d ' % i, ' of %d' % N0)
        i += 1
        N1 = len(newy)
        if N1 > (Nval-N0):
            break  # we have enough samples
        # add originals
        #newX = np.concatenate(X, newX)
        #newy = np.concatenate(y, newy)
    return newX, newy, (N1+N0)

# initialize arrays
data = np.asarray([])
labels = np.asarray([])
data_new = np.asarray([])
labels_new = list()
DATA = np.asarray([])

cnt = 0
for elem in datalist:
    # load datasets for training and validation
    rawdata = load(rootpath + stem + elem + '.npz')
    data_i, labels_i = rawdata['arr_0'], rawdata['arr_1']
    if not cnt:
        data = data_i
        labels = labels_i
    else:
        data = np.concatenate([data, data_i])
        labels = np.concatenate([labels, labels_i])
    cnt = cnt + 1

# initialize age list based on age bounds
agelist = np.unique(labels)
agebounds = np.where((agelist >= lower_age) & (agelist < upper_age))
agebounds = np.reshape(agebounds, np.shape(agebounds)[1])
agelist = agelist[int(agebounds[0]):int(agebounds[-1])]
agepool = [[] for i in range(agelist[-1])]

# Randomly rebalance dataset
for age in agelist:
    indx = np.where(labels == age)
    cnt = len(indx[0])
    print('(%d, ' % age, '%d)' % cnt)
    rindx = np.random.permutation(cnt)
    temp = [indx[0][i] for i in rindx]
    agepool[age - 1].append(temp)
data_cnt = 0
for i in range(Nval):
    cnt = 0
    for age in agelist:
        if i > (len(agepool[age - 1][0]) - 1):
            continue
        indx_i = agepool[age - 1][0][i]
        data_i = data[indx_i,:,:,:]
        data_i = np.expand_dims(data_i, axis=0)
        labels_i = labels[indx_i]
        if not cnt:
            data_new = data_i
        else:
            data_new = np.concatenate([data_new, data_i])
        labels_new.append(labels_i)
        cnt = cnt + 1
    if not data_cnt:
        DATA = data_new
    else:
        DATA = np.concatenate([DATA, data_new])
    del data_new
    data_cnt = data_cnt+1
    data_new = np.asarray([])
    print('Processing iteration %d' % (i + 1), 'of %d,' % Nval)

print('Final dataset: ')
total_cnt = 0
newX = np.asarray([])
newy = np.asarray([])
labels_new = np.asarray(labels_new)
data_cnt = 0
new_cnt = 0

# process batches for augmentation by age
for age in agelist:
    indx = np.where(labels_new == age)
    cnt = len(indx[0])
    newX, newy, new_cnt = augment(DATA[indx[0],:,:,:], labels_new[indx], Nval, datagen, batchsz)
    new_cnt = len(newy)
    DATA = np.concatenate([DATA, newX])
    labels_new = np.concatenate([labels_new, newy])
    total_cnt = total_cnt + new_cnt
    data_cnt = data_cnt + 1
    print('(Age: %d , ' % age, 'new N: %d)' % new_cnt)
print('\n N: new dataset %d' % total_cnt)

# randomly shuffle the dataset
rindx = np.random.permutation(np.shape(DATA)[0])
DATA = DATA[rindx,:,:,:]
labels_new = labels_new[rindx]

# write rebalanced and augmented dataset to file
print('Saving data to file...')
savez_compressed(rootpath + 'extracted_faces_R.npz', DATA, labels_new)
print('Done.')

# show distribution of starting dataset (old) vs. rebalanced and augmented dataset (new)
plt.hist(labels, bins = len(agelist))
plt.title('Old dataset age distribution')
plt.figure()
plt.hist(labels_new, bins = len(agelist))
plt.title('New dataset age distribution')
plt.show()
