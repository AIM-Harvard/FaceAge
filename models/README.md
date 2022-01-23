# Models

This folder should store the pre-trained weights of the FaceAge model (`faceage_model.h5`).

The pre-trained weights will be made available upon publication via [Zenodo](https://zenodo.org).

## Model Description

The FaceAge deep learning pipeline comprises two stages: a face localization and extraction stage, and a feature-encoding stage with output linear regressor that provides the continuous estimate of biological age.

![models-pipeline_overview](../assets/FaceAge-Model-Diagram.SVG)

The first stage pre-processes the input data by locating the face within the photograph and defines a bounding box around it. The image is then cropped, resized, and pixel values standard-normalized across all RGB channels. Face extraction is accomplished using [a multi-task cascaded CNN (MTCNN)](https://github.com/ipazc/mtcnn) implemented by Zhang et al. (IEEE Signal Processing Letters 23, 1499–1503, 2016). The extraction network is comprised of three sub-networks, namely a proposal network (P-net) that creates an initial set of bounding box candidates, of which similar boxes are merged then further refined (R-net) using bounding box regression and face landmark localization, then the third stage (O-net) makes more stringent use of face landmarks to optimize the final bounding box, achieving a cited test accuracy of 95%. For additional details, please refer to the project repository.

The second stage of the pipeline takes the extracted face image and feeds it into a convolutional neural network (CNN) that encodes image features into a 128-dimensional embedding vector, which through regression yield a continuous FaceAge prediction as the output. This model (whose pre-trained weights will be made available upon publication) uses an inception-ResNet v1 architecture, whose layers progressively embed higher-order facial features into lower-dimensional representations, yielding a 128-dimensional face embedding that is then fed through a linear regression layer to produce the continuous biological age estimate as the final output. The original Inception-ResNet v1 CNN weights were pre-trained on the problem of facial recognition by Sandberg (https://github.com/davidsandberg/facenet), whereby it achieved a test accuracy of 98% on the “Local Faces in the Wild” database (http://vis-www.cs.umass.edu/lfw/results.html) (see project repository for details). The network was adapted to biological age estimation by removing the output classification layer and replacing it with densely connected layers feeding a fully-connected output layer with linear activation function to perform the regression. Transfer learning was then applied to tune the weights of the last 281 of the 426 Inception-ResNet v1 layers (Inception Block B1 onward) in addition to the fully-connected output layers, using the augmented and randomly rebalanced training dataset of N = 56,304 age-labelled face images derived from the IMDb-Wiki database (see [Augmentation and Rebalancing](../data#augmentation-and-rebalancing)). The photographs age-labeled from 60 years old and onward were manually curacted to ensure image quality control and reduce error from noisy labels (see 





## Model Training
