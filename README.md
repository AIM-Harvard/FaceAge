# FaceAge

[Paper title and link]

If you use code or parts of this code in your work, please cite our 
publication:  [paper citation]

[Journal logo]


## Repository Structure

The FaceAge repository is structured as follows:

* All the source code to run [...] is found under the `src` folder.
* ...

Additional details on the content of the subdirectories and their structure can be found in the markdown files stored in each of the subdirectories.

## Setup

This code was developed and tested using Python 2.7.17 on Ubuntu 18.04 with Cuda 10.1 and libcudnn 7.6.

The pipeline was also tested using Python 3.6.13 on Ubuntu 18.04 with Cuda 11.3.1 and libcudnn 8.2.1.

The statistical analysis was conducted using R (Version 3.6.3) in an RStudio environment (Version 1.4.1106).

<br>

For the code to run as intended, all the packages under `requirements.txt` should be installed. In order not to break previous installations and ensure full compatibility, it's highly recommended to create a virtual environment to run the FaceAge pipeline in. Here follows an example of set-up using `python virtualenv`:

```
# install python's virtualenv
sudo pip install virtualenv

# parse the path to the python2 interpreter
export PY2PATH=$(which python2)

# create a virtualenv with such python2 interpreter named "venv"
# (common name, already found in .gitignore)
virtualenv -p $PY2PATH venv 

# activate the virtualenv
source venv/bin/activate
```

At this point, `(venv)` should be displayed at the start of each bash line. Furthermore, the command `which python2` should return a path similar to `/path/to/folder/venv/bin/python2`. Once the virtual environment is activated:

```
# once the virtualenv is activated, install the dependencies
pip install -r requirements.txt
```

At this stage, everything should be ready for the data to be processed by the FaceAge pipeline. Additional details can be found in the markdown file under `src`.

The virtual environment can be deactivated by running:

```
deactivate
```

<br>

Alternatively, one could create and setup a Conda environment:

```
>> Instruction for setting everything up with Conda
```


## Acknowledgements

Code development, testing, refactoring and documentation: Osbert Zalay and Dennis Bontempi.

## Disclaimer

The code and data of this repository are provided to promote reproducible 
research. They are not intended for clinical care or commercial use.

The software is provided "as is", without warranty of any kind, express or 
implied, including but not limited to the warranties of merchantability, 
fitness for a particular purpose and noninfringement. In no event shall the 
authors or copyright holders be liable for any claim, damages or other 
liability, whether in an action of contract, tort or otherwise, arising 
from, out of or in connection with the software or the use or other 
dealings in the software.

## Example data

[link to the example notebooks here]

