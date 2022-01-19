# Notebooks

This folder stores some tutorial notebooks we developed to allow for quick experimentation with our pipeline.

The notebooks can be downloaded and run locally (provided the right environment is set up - see the main `README` for detailed instructions), or opened directly in Google Colab by clicking the "Open with Colab" buttons below.

## Data Processing Demo

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/AIM-Harvard/FaceAge/blob/main/notebooks/data_processing_demo.ipynb)

This notebook allows the user to understand how to run the FaceAge pipeline (i.e., how is the pipeline set-up, how to format the input, and what to expect as the output), as well as estimate the computational costs of the operation involved.

The data required to run the notebook will be made available through [Zenodo](https://zenodo) upon publication.


Here follows a sample from the notebook:

![notebooks-data_processing](../assets/notebooks-data_processing.png)

```
Age:      62
FaceAge:  63.252663

Gender:   0 (Male)
Race:     0 (White)
```

## Extended Data Plots Demo 

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/AIM-Harvard/FaceAge/blob/main/notebooks/extended_data_plots_demo.ipynb)

This notebook allows the user to reproduce some of the figures in the Extended Data document.

Any small difference in the quantitative results is due to a difference between the versions of the dependencies used to conduct the final analysis in the paper, and the version of such dependencies on Google Colab.

Other differences in the plots appearance are due to the fact the figure in the Extended Data were exported with R, while the notebook was written in python only.


Here follows a sample from the notebook:

![notebooks-extended_data](../assets/notebooks-extended_data.png)



