# FaceAge

[Graphical abstract?]

[Paper title and link?]

If you use code or parts of this code in your work, please cite our 
publication:  [paper citation]

[Journal logo]


# Table of Contents

- [Repository Structure](#repository-structure)
- [Environment Setup and Dependencies](#environment-setup-and-dependencies)
  - [Running the Pipeline on a Machine Equipped With a Gpu](#running-the-pipeline-on-a-machine-equipped-with-a-gpu)
  - [Running the Pipeline on a Machine Without a Gpu](#running-the-pipeline-on-a-machine-without-a-gpu)
- [Acknowledgements](#acknowledgements)
- [Disclaimer](#disclaimer)
  

# Repository Structure

This repository is structured as follows:

* The `src` folder stores the code used to train and test the pipeline;
* The `stats` folder stores the code used in the statistical analysis, and to export the plots in the Main Manuscript and in the Extended Data;
* The `models` folder stores the pre-trained weights for the FaceAge model;
* The `data` folder stores the code used for data processing (from the database curation to the processing of some of the results, e.g., the survey in Figure 4 of the Main Manuscript), along with the links to retrieve the data shared with the publication;
* The `outputs` folder stores a sample of the output from the pipeline;
* The `notebooks` folder stores some demo resources useful to understand how the pipeline works and reproduce the first figures in the Extended Data.

Additional details on the content of the subdirectories and their structure can be found in the markdown files stored in each of the subdirectories.


# Environment Setup and Dependencies

This code was developed and tested using Python 2.7.17 on Ubuntu 18.04 with Cuda 10.1 and libcudnn 7.6.

The pipeline was also tested using the environment described in the `environment-gpu.yaml` file (Python 3.6.13, CUDA 11.3.1, and libcudnn 8.2.1 - on Ubuntu 18.04), the environment described in `environment-cpu.yaml` (i.e., the same packages - but without GPU acceleration), and using the freely accessible Google Colab notebook (Python 3.7.12, CUDA 11.1, and libcudnn 7.6.5 - on Ubuntu 18.04). We recommend running the pipeline on an up-to-date environment to avoid [known problems](https://github.com/ipazc/mtcnn/issues/87) with the `MTCNN` library.

The statistical analysis was conducted using R (Version 3.6.3) in an RStudio environment (Version 1.4.1106).

<br>

For the code to run as intended, the all the packages under one of the environment files should be installed. In order not to break previous installations and ensure full compatibility, it's highly recommended to create a Conda environment to run the FaceAge pipeline in. Here follows two examples of the set-up procedure using Conda and one of the provided YAML environment files.

## Running the Pipeline on a Machine Equipped With a Gpu

GPU acceleration can speed up the FaceAge estimation dramatically. If your machine is equipped with a GPU that supports CUDA compute capability, you can set up the Conda environment running the following:

```
# set-up Conda faceage-test environment
conda env create --file environment-gpu.yaml

# activate the conda environment
conda activate faceage-gpu
```

At this point, `(faceage-gpu)` should be displayed at the start of each bash line. Furthermore, the command `which python` should return a path similar to `$PATH_TO_CONDA_FOLDER/faceage-gpu/bin/python`. You can check your GPU is correctly identified by the environment (and thus, the GPU acceleration available) by spawning a `python` shell (after activating the Conda environment), and running:

```
import tensorflow as tf
tf.config.list_physical_devices('GPU')
```

If the set-up was successful, you should get an output similar to the following:

```
>>> tensorflow.config.list_physical_devices('GPU')
[PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]
```

Everything should now be ready for the data to be processed by the FaceAge pipeline.

The virtual environment can be deactivated by running:

```
conda deactivate
```

## Running the Pipeline on a Machine Without a Gpu

Running the FaceAge pipeline without GPU acceleration is possible, although this might increase considerably the processing times. If your machine is not equipped with a GPU that supports CUDA compute capability, you can set up the Conda environment running the following::

```
# set-up Conda faceage-test environment
conda env create --file environment-cpu.yaml

# activate the conda environment
conda activate faceage-cpu
```

At this point, `(faceage-cpu)` should be displayed at the start of each bash line. Furthermore, the command `which python` should return a path similar to `$PATH_TO_CONDA_FOLDER/faceage-cpu/bin/python`. Everything should now be ready for the data to be processed by the FaceAge pipeline.

The virtual environment can be deactivated by running:

```
conda deactivate
```


# Acknowledgements

Code development, testing, refactoring and documentation: Osbert Zalay and Dennis Bontempi.


# Disclaimer

The code and data of this repository are provided to promote reproducible 
research. They are not intended for clinical care or commercial use.

The software is provided "as is", without warranty of any kind, express or 
implied, including but not limited to the warranties of merchantability, 
fitness for a particular purpose and noninfringement. In no event shall the 
authors or copyright holders be liable for any claim, damages or other 
liability, whether in an action of contract, tort or otherwise, arising 
from, out of or in connection with the software or the use or other 
dealings in the software.

