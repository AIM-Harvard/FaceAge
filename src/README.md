# Source Code

This folder stores the code used to train and test the pipeline.

A list of the pipeline dependencies, as well as a quick guide on how to set-up the environment to run the pipeline, can be found in the main `README`.


# Testing Code

In the `test` folder, we provide a simple script (`predict_folder_demo.py`) to process all the `.jpg` and `.png` files in a given directory.

By default, the script reads the images to process from a folder whose name is specified in the `config_predict_folder_demo.yaml` configuration file (`input_folder_name`). The absolute path to the folder is determined from `base_path` and `data_folder_name` as well (by default, the script will look for a folder at `$base_path/$data_folder_name/$input_folder_name`):

```
$base_path
└── $data_folder_name
    └── $input_folder_name
        ├── subj1.jpg
        ├── subj2.jpg
        ├── subj3.jpg
        ...
```

The folder can contain files that are not `.png` and `.jpg`, as only these formats will be read and processed. Here follows an example of how a folder should look like:

```
~/git/FaceAge
└── data
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
The `config_predict_folder_demo.yaml` configuration file is parsed by the script to determine also the path to the pre-trained model file (`$base_path/$models_folder_name/$model_name`), and the path to the folder where outputs (predictions) will be stored (`$base_path/$outputs_folder_name` - by default, stored under `${input_folder_name}.csv`).

<br>

A documented Google Colab notebook implementing very similar operations is provided as part of the repository (see under `notebooks` for the notebooks and how to open them in Colab directly). The code can be easily adapted to suit the users need.

Here follows a sample output from the `predict_folder_demo.py` script, executed on a machine equipped with a NVIDIA TITAN RTX, after setting up from scratch the `faceage-gpu` Conda environment:

```
(faceage-gpu) dennis@R2-D2:~/git/FaceAge/src/test$ python -W ignore predict_folder_demo.py 
Python version     :  3.6.13 |Anaconda, Inc.| (default, Jun  4 2021, 14:25:59) 
TensorFlow version :  2.6.2
Keras version      :  2.6.0
Numpy version      :  1.19.5

Predicting FaceAge for 2547 subjects at: '/home/dennis/git/FaceAge/data/utk_hi-res_qa'

(2547/2547) Running the face localization step for "28_0_4_20170117202427928.jpg""
... Done in 2013.39 seconds.

(2547/2547) Running the age estimation step for "28_0_4_20170117202427928""
... Done in 95.157 seconds.

Saving predictions at: '/home/dennis/git/FaceAge/outputs/utk_hi-res_qa_res.csv'... Done.
```

Finally, here follows the output of `predict_folder_demo.py` ran on the same machine, without exploiting the GPU (rather, using an AMD Ryzen 7 3800X 8-Core; the system is equipped with 64 GBs of RAM). Given the system specifications, the nature of the operations involved and the lightweight models, the performances during the inference phase are comparable:

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
