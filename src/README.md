# Source Code

This folder stores the code used to train and test the pipeline.

A list of the pipeline dependencies, as well as a quick guide on how to set-up the environment to run the pipeline, can be found in the main README.


# Training Code

[add description here]

# Testing Code

In the `test` folder, we provide a simple script (`predict_folder_demo.py`) to process all the `.jpg` and `.png` files in a given directory.

By default, the script reads the images to process from a folder whose name is specified in the `config_predict_folder_demo.yaml` configuration file.


```
.
└── utk_hi-res_qa
    ├── 100_1_0_20170112213303693.jpg
    ├── 100_1_0_20170117195420803.jpg
    ├── 100_1_0_20170119212053665.jpg
    ├── 20_0_0_20170104230051977.jpg
    ├── 20_0_0_20170110232156775.jpg
    ├── 20_0_0_20170117134213422.jpg
    ├── 20_0_0_20170117140056058.jpg
    ...
```

Furthermore, a documented Google Colab notebook implementing very similar operations is provided as part of the repository (see under `notebooks`). The code can be easily adapted to suit the users need.

Here follows a sample output from the `predict_folder_demo.py` script, executed on a machine equipped with a NVIDIA TITAN RTX, after setting up from scratch the `faceage-gpu` Conda environment:

```
(faceage-gpu) dennis@R2-D2:~/git/FaceAge/src/test$ python -W ignore predict_folder_demo.py 
Python version     :  3.6.13 |Anaconda, Inc.| (default, Jun  4 2021, 14:25:59) 
TensorFlow version :  2.6.2
Keras version      :  2.6.0
Numpy version      :  1.19.5

Predicting FaceAge for 2547 subjects at: '/home/dennis/git/FaceAge/data/utk_hi-res_qa'

(2547/2547) Running the face localization step for "28_0_4_20170117202427928.jpg"
... Done in 2024.72 seconds.

(2547/2547) Running the age estimation step for "28_0_4_20170117202427928"
... Done in 78.1542 seconds.

Saving predictions at: '/home/dennis/git/FaceAge/outputs/utk_hi-res_qa_res.csv'... Done.
```

Finally, `predict_folder_demo.py` ran on the same machine, without exploiting the GPU (rather, using an AMD Ryzen 7 3800X 8-Core; the system is equipped with 64 GBs of RAM). Given the nature of the operations involved and the lightweight models, it is no surprise the performances during the inference phase are comparable:

```
(faceage-cpu) dennis@R2-D2:~/git/FaceAge/src/test$ python -W ignore predict_folder_demo.py 
Python version     :  3.6.13 |Anaconda, Inc.| (default, Jun  4 2021, 14:25:59) 
TensorFlow version :  2.6.2
Keras version      :  2.6.0
Numpy version      :  1.19.5

Predicting FaceAge for 2547 subjects at: '/home/dennis/git/FaceAge/data/utk_hi-res_qa'

(2547/2547) Running the face localization step for "28_0_4_20170117202427928.jpg""
... Done in 1773.17 seconds.

(2547/2547) Running the age estimation step for "28_0_4_20170117202427928""
... Done in 108.407 seconds.

Saving predictions at: '/home/dennis/git/FaceAge/outputs/utk_hi-res_qa_res.csv'... Done.
```