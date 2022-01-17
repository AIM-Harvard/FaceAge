# Data

This folder contains data processing and quality assurance files, used to prepare the clinical (HARVARD) and model development datasets. A description of each file is provided below.

This README also contains the links to retrieve the data shared with the publication.


# Table of Contents

- [Augmentation and Rebalancing](#augmentation-and-rebalancing)
- [Database Processing](#database-processing)
- [Database Curation](#database-curation)
- [Survey Data Processing](#survey-data-processing)
- [Manual Quality Assurance](#manual-quality-assurance)
- [Example of Acceptable Image](#example-of-acceptable-image)
- [Example of Disqualified Image](#example-of-disqualified-image)
- [Link to the Shared Data](#link-to-the-shared-data)


# Augmentation and Rebalancing

The script takes the source database of age-labelled photographs and creates a balanced dataset for model training and development via augmentation and randomized rebalancing. The user defines a target number of samples per age category, age range of the processed dataset, and batch size for augmentation. The augmentation is done using the ImageDataGenerator functionality in Keras:

```
# example instantiation of ImageDataGenerator object for augmentation
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
 ```

The randomized rebalancing randomly shuffles samples from each each category to supplement the augmented samples until the target number of samples per age category is achieved, in order to achieve an approximate uniform distribution

![image](https://user-images.githubusercontent.com/25285692/149670666-3b30e552-1458-4d9f-a8b5-2a667ceaf7b4.png)


# Database Processing

The script takes `logfile.csv`, which contains the clinical image hashes pertaining to patient photographs stored on the hospital EMR, and maps them to the clinical database of respective patient prognostic factors and outcomes collectively prospectively; e.g. stored on `REDcap` clinical data e-repository at Harvard MGH/BWH. No clinical information is provided in this repo (including the contents of `logfile.csv`) due to privacy conditions.


# Database Curation

This script applies inclusion and exclusion criteria (as described in the manuscript) to the output of `Database_Processing.py` and calculates survival times, follow-up times and events in order to obtain the curated database used for statistical and survival analyses.


# Survey Data Processing

This script was used to import the human survey data from part 1 and 2 (stored on `REDcap` clinical data e-repository at Harvard MGH/BWH; see manuscript for further details) and map those to respective patient prognostic factors and outcomes, to create an output `.csv` file used for statistical analyses of survey results that compares human performance to machine performance in survival prediction for palliative cancer patients.


# Manual Quality Assurance

This script was used to manually cull images that met the photo QA exclusion criteria listed in the manuscript (from Supplement Table 1):

![image](https://user-images.githubusercontent.com/25285692/149672742-550d2a55-2f6c-4b4e-873d-cd74eb04f2f6.png)

## Example of Acceptable Image
![image](https://user-images.githubusercontent.com/25285692/149672917-6a97f45c-d367-4d09-907d-a6dfd5da2795.png)

## Example of Disqualified Image
Exclusion reason:  the original photograph has more than one face.
![image](https://user-images.githubusercontent.com/25285692/149672609-f949da55-7969-4aec-af3f-f3be5a7c31cc.png)


# Link to the Shared Data

[link to and description of the shared data goes here?]

